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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Service for synchronizing playlist data from FFT Battleground XML feed
 */
@Service
public class PlaylistSyncService {

    private static final Logger logger = LoggerFactory.getLogger(PlaylistSyncService.class);
    private static final String PLAYLIST_URL = "http://www.fftbattleground.com/fftbg/playlist.xml";

    @Autowired
    private SongRepository songRepository;

    /**
     * Initial sync when application starts (async to avoid blocking startup)
     */
    @PostConstruct
    public void initialSync() {
        logger.info("Starting initial playlist synchronization...");
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
     * Synchronize playlist data from XML feed
     */
    @Transactional
    public void syncPlaylist() {
        try {
            List<Song> xmlSongs = fetchSongsFromXml();
            
            if (xmlSongs.isEmpty()) {
                logger.warn("No songs found in XML feed, skipping sync");
                return;
            }

            // Get existing song titles from database
            Set<String> existingTitles = new HashSet<>();
            for (Song dbSong : songRepository.findAll()) {
                if (dbSong.getTitle() != null) {
                    existingTitles.add(dbSong.getTitle());
                }
            }

            // Add new songs
            List<Song> newSongs = new ArrayList<>();
            for (Song xmlSong : xmlSongs) {
                if (xmlSong.getTitle() != null && !existingTitles.contains(xmlSong.getTitle())) {
                    newSongs.add(xmlSong);
                }
            }

            if (!newSongs.isEmpty()) {
                songRepository.saveAll(newSongs);
                logger.info("Added {} new songs to database", newSongs.size());
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
                String rawTitle = leafElement.getAttribute("name");

                if (rawTitle != null && !rawTitle.trim().isEmpty()) {
                    Song song = new Song();
                    
                    // Clean up the song title
                    String cleanTitle = cleanSongTitle(rawTitle);
                    song.setTitle(cleanTitle);
                    
                    // Set creation timestamp
                    song.setCreatedAt(LocalDateTime.now());
                    
                    songs.add(song);
                }
            }

        } catch (Exception e) {
            logger.error("Error fetching songs from XML feed", e);
        }

        return songs;
    }

    /**
     * Clean up song title by removing file extensions and extra characters
     */
    private String cleanSongTitle(String rawTitle) {
        if (rawTitle == null) return null;
        
        String cleaned = rawTitle;
        
        // Remove common audio file extensions
        cleaned = cleaned.replaceAll("\\.(mp3|wav|flac|m4a|ogg|wma)$", "");
        
        // Remove leading numbers and dashes (track numbers)
        cleaned = cleaned.replaceAll("^\\d+[-\\s]*", "");
        
        // Clean up extra whitespace
        cleaned = cleaned.trim().replaceAll("\\s+", " ");
        
        return cleaned;
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