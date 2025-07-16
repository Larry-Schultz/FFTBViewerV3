package com.twitchchat.service;

import com.twitchchat.model.Song;
import com.twitchchat.repository.SongRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.annotation.PostConstruct;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/**
 * Service for synchronizing playlist data from FFT Battleground XML feed
 */
@Service
public class PlaylistSyncService {

    private static final Logger logger = LoggerFactory.getLogger(PlaylistSyncService.class);
    private static final String PLAYLIST_URL = "http://www.fftbattleground.com/fftbg/playlist.xml";
    private final Object syncLock = new Object(); // Prevent concurrent sync operations

    @Autowired
    private SongRepository songRepository;

    /**
     * Initial sync when application starts (async to avoid blocking startup)
     */
    @PostConstruct
    public void initialSync() {
        logger.info("Starting initial playlist synchronization with URI-based parsing...");
        new Thread(() -> {
            try {
                Thread.sleep(5000); // Wait 5 seconds for app to fully start
                syncPlaylist();
            } catch (Exception e) {
                logger.error("Initial sync failed", e);
            }
        }).start();
    }

    /**
     * Scheduled sync every 30 minutes
     */
    @Scheduled(fixedRate = 30 * 60 * 1000) // 30 minutes in milliseconds
    public void scheduledSync() {
        logger.info("Starting scheduled playlist synchronization...");
        syncPlaylist();
    }

    /**
     * Synchronize playlist data from XML feed (synchronized to prevent race conditions)
     */
    @Transactional
    public void syncPlaylist() {
        synchronized (syncLock) {
            doSyncPlaylist();
        }
    }
    
    /**
     * Internal sync method (called within synchronized block)
     */
    private void doSyncPlaylist() {
        try {
            List<Song> xmlSongs = fetchSongsFromXml();
            
            if (xmlSongs.isEmpty()) {
                logger.warn("No songs found in XML feed, skipping sync");
                return;
            }
            
            logger.info("Fetched {} songs from XML feed", xmlSongs.size());

            // Get existing song titles from database (more efficient than loading all songs)
            List<String> existingTitlesList = songRepository.findAllTitles();
            Set<String> existingTitles = new HashSet<>(existingTitlesList);
            logger.info("Found {} existing songs in database", existingTitles.size());

            // Add new songs (keeping unique titles only, prevent duplicates)
            List<Song> newSongs = new ArrayList<>();
            Set<String> processedTitles = new HashSet<>();
            
            for (Song xmlSong : xmlSongs) {
                String title = xmlSong.getTitle();
                if (title != null && !title.trim().isEmpty() && !processedTitles.contains(title)) {
                    processedTitles.add(title);
                    
                    // Only add if it doesn't exist in database
                    if (!existingTitles.contains(title)) {
                        // Add new song with occurrence = 0 (will be tracked by SongPlayTracker)
                        xmlSong.setOccurrence(0);
                        newSongs.add(xmlSong);
                    }
                }
            }

            if (!newSongs.isEmpty()) {
                logger.info("Processing {} new songs for database insertion", newSongs.size());
                
                // Process in smaller batches for better performance with large datasets
                int batchSize = 500;
                int totalBatches = (int) Math.ceil((double) newSongs.size() / batchSize);
                logger.info("Processing {} songs in {} batches", newSongs.size(), totalBatches);
                
                for (int i = 0; i < newSongs.size(); i += batchSize) {
                    int endIndex = Math.min(i + batchSize, newSongs.size());
                    List<Song> batch = newSongs.subList(i, endIndex);
                    int currentBatch = (i / batchSize) + 1;
                    
                    try {
                        // Use saveAll with exception handling for potential duplicate key violations
                        songRepository.saveAll(batch);
                        logger.info("Batch {}/{} completed: Saved {} songs (Total: {}/{})", 
                                  currentBatch, totalBatches, batch.size(), endIndex, newSongs.size());
                    } catch (Exception e) {
                        // Handle potential duplicate key violations gracefully
                        if (e.getMessage() != null && e.getMessage().contains("duplicate key")) {
                            logger.warn("Duplicate key violation in batch {}/{} - some songs may already exist, continuing", 
                                      currentBatch, totalBatches);
                            // Try saving songs individually to identify which ones are duplicates
                            for (Song song : batch) {
                                try {
                                    songRepository.save(song);
                                } catch (Exception singleSaveError) {
                                    logger.debug("Skipped duplicate song: {}", song.getTitle());
                                }
                            }
                        } else {
                            logger.error("Error saving batch {}/{}", currentBatch, totalBatches, e);
                            throw e; // Re-throw for other types of errors
                        }
                    }
                }
                
                logger.info("Successfully added {} new songs to database", newSongs.size());
            } else {
                logger.info("No new songs to add, database is up to date");
            }

            long totalSongs = songRepository.countAllSongs();
            logger.info("Playlist sync completed. Total songs in database: {}", totalSongs);

        } catch (Exception e) {
            logger.error("Error during playlist synchronization", e);
        }
    }

    /**
     * Fetch songs from XML feed and parse them
     */
    private List<Song> fetchSongsFromXml() {
        List<Song> songs = new ArrayList<>();

        try {
            logger.info("Fetching playlist from: {}", PLAYLIST_URL);
            
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new URL(PLAYLIST_URL).openStream());

            NodeList leafNodes = document.getElementsByTagName("leaf");
            logger.info("Found {} songs in XML feed", leafNodes.getLength());

            for (int i = 0; i < leafNodes.getLength(); i++) {
                Element leafElement = (Element) leafNodes.item(i);
                String uriStr = leafElement.getAttribute("uri");
                String durationStr = leafElement.getAttribute("duration");

                if (uriStr != null && !uriStr.trim().isEmpty()) {
                    Song song = new Song();
                    
                    // Extract and clean song title from URI
                    String cleanTitle = extractTitleFromUri(uriStr);
                    if (cleanTitle != null && !cleanTitle.trim().isEmpty()) {
                        song.setTitle(cleanTitle);
                    
                    // Parse and format duration from seconds to MM:SS format
                    if (durationStr != null && !durationStr.trim().isEmpty()) {
                        try {
                            int totalSeconds = Integer.parseInt(durationStr.trim());
                            String formattedDuration = formatDuration(totalSeconds);
                            song.setDuration(formattedDuration);
                            logger.debug("Parsed duration for '{}': {} seconds -> {}", cleanTitle, totalSeconds, formattedDuration);
                        } catch (NumberFormatException e) {
                            logger.warn("Could not parse duration '{}' for song '{}'", durationStr, cleanTitle);
                        }
                    } else {
                        logger.debug("No duration found for song '{}'", cleanTitle);
                    }
                    
                    // Set creation timestamp
                    song.setCreatedAt(LocalDateTime.now());
                    
                        songs.add(song);
                    } else {
                        logger.debug("Could not extract valid title from URI: {}", uriStr);
                    }
                }
            }

        } catch (Exception e) {
            logger.error("Error fetching songs from XML feed", e);
        }

        return songs;
    }

    /**
     * Extract song title from URI field using proper URL decoding
     * Example: file:///C:/sharec/FFTBattleground-battle/4%20Elements%20II%20-%20World%20of%20Magic.mp3
     * Returns: 4 Elements II - World of Magic
     */
    private String extractTitleFromUri(String uri) {
        if (uri == null || uri.trim().isEmpty()) {
            return null;
        }
        
        try {
            // Expected pattern: file:///C:/sharec/FFTBattleground-battle/FILENAME.mp3
            String prefix = "file:///C:/sharec/FFTBattleground-battle/";
            String suffix = ".mp3";
            
            if (uri.startsWith(prefix) && uri.endsWith(suffix)) {
                // Extract the filename part between prefix and suffix
                String encodedFilename = uri.substring(prefix.length(), uri.length() - suffix.length());
                
                // URL decode the filename
                String decodedFilename = URLDecoder.decode(encodedFilename, StandardCharsets.UTF_8);
                
                // Clean up the title
                String cleanTitle = cleanSongTitle(decodedFilename);
                
                logger.debug("Extracted title from URI '{}': '{}'", uri, cleanTitle);
                return cleanTitle;
            } else {
                logger.warn("URI does not match expected pattern: {}", uri);
                return null;
            }
        } catch (Exception e) {
            logger.error("Error extracting title from URI: {}", uri, e);
            return null;
        }
    }

    /**
     * Clean up song title by removing unwanted characters and formatting
     */
    private String cleanSongTitle(String rawTitle) {
        if (rawTitle == null || rawTitle.trim().isEmpty()) {
            return rawTitle;
        }
        
        String cleanTitle = rawTitle.trim();
        
        // Replace underscores with spaces
        cleanTitle = cleanTitle.replace("_", " ");
        
        // Remove multiple spaces and trim
        cleanTitle = cleanTitle.replaceAll("\\s+", " ").trim();
        
        return cleanTitle;
    }

    /**
     * Format duration from seconds to MM:SS or H:MM:SS format
     */
    private String formatDuration(int totalSeconds) {
        int hours = totalSeconds / 3600;
        int minutes = (totalSeconds % 3600) / 60;
        int seconds = totalSeconds % 60;
        
        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, seconds);
        } else {
            return String.format("%d:%02d", minutes, seconds);
        }
    }

    /**
     * Get total song count from database
     */
    public long getTotalSongCount() {
        return songRepository.countAllSongs();
    }

    /**
     * Force manual sync (for admin/testing purposes)
     */
    public void forceSyncPlaylist() {
        logger.info("Manual playlist sync triggered");
        syncPlaylist();
    }
}