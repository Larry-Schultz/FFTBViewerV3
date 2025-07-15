package com.twitchchat.service;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import com.twitchchat.model.Playlist;
import com.twitchchat.model.Song;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Service to fetch and parse the FFT Battleground playlist XML
 */
@Service
public class PlaylistService {
    private static final Logger logger = LoggerFactory.getLogger(PlaylistService.class);
    private static final String PLAYLIST_URL = "http://www.fftbattleground.com/fftbg/playlist.xml";
    
    private final RestTemplate restTemplate;
    
    public PlaylistService() {
        // Configure RestTemplate with proper timeouts for slow external service
        this.restTemplate = new RestTemplateBuilder()
                .setConnectTimeout(Duration.ofSeconds(10))
                .setReadTimeout(Duration.ofSeconds(30))
                .build();
    }
    private final XmlMapper xmlMapper = new XmlMapper();

    /**
     * Fetch songs from the FFT Battleground playlist XML
     */
    public List<Song> fetchSongs() {
        try {
            logger.info("Fetching playlist from: {}", PLAYLIST_URL);
            
            // Fetch XML content
            String xmlContent = restTemplate.getForObject(PLAYLIST_URL, String.class);
            
            if (xmlContent == null || xmlContent.trim().isEmpty()) {
                logger.warn("Empty XML content received from playlist URL");
                return createFallbackSongs();
            }
            
            logger.info("Successfully fetched XML content ({} characters)", xmlContent.length());
            logger.debug("XML Content preview: {}", xmlContent.substring(0, Math.min(200, xmlContent.length())));
            
            // Try different parsing approaches
            List<Song> songs = parseXmlContent(xmlContent);
            
            if (songs.isEmpty()) {
                logger.warn("No songs parsed from XML, using fallback data");
                return createFallbackSongs();
            }
            
            logger.info("Successfully parsed {} songs from playlist", songs.size());
            return songs;
            
        } catch (Exception e) {
            logger.error("Error fetching playlist from {}: {} - {}", PLAYLIST_URL, e.getClass().getSimpleName(), e.getMessage());
            logger.info("Using fallback songs due to external service unavailability");
            return createFallbackSongs();
        }
    }

    private List<Song> parseXmlContent(String xmlContent) {
        try {
            // Try to parse as Playlist object first
            Playlist playlist = xmlMapper.readValue(xmlContent, Playlist.class);
            
            if (playlist != null && playlist.getTrackList() != null && playlist.getTrackList().getTracks() != null) {
                return playlist.getTrackList().getTracks();
            }
            
            // If that fails, try direct parsing of track elements
            logger.info("Direct playlist parsing failed, trying alternative approach");
            return parseAlternativeFormat(xmlContent);
            
        } catch (Exception e) {
            logger.warn("XML parsing failed: {}", e.getMessage());
            return parseAlternativeFormat(xmlContent);
        }
    }

    private List<Song> parseAlternativeFormat(String xmlContent) {
        // Parse the specific FFT Battleground XML format with <leaf> elements
        List<Song> songs = new ArrayList<>();
        
        // Extract leaf elements with name attributes
        String[] lines = xmlContent.split("\n");
        for (String line : lines) {
            if (line.contains("<leaf") && line.contains("name=")) {
                String songName = extractNameAttribute(line);
                String duration = extractDurationAttribute(line);
                
                if (songName != null && !songName.trim().isEmpty() && 
                    !songName.equals("Playlist") && !songName.contains("node")) {
                    
                    // Clean up the song name (remove .mp3, decode HTML entities)
                    songName = cleanSongName(songName);
                    songs.add(new Song(songName, "FFT Battleground", "Live Playlist", duration != null ? formatDuration(duration) : "Unknown"));
                }
            }
        }
        
        logger.info("Parsed {} songs using alternative XML format", songs.size());
        return songs;
    }

    private String extractNameAttribute(String line) {
        // Extract value from name="..." attribute
        int nameStart = line.indexOf("name=\"");
        if (nameStart == -1) return null;
        
        nameStart += 6; // Skip 'name="'
        int nameEnd = line.indexOf("\"", nameStart);
        if (nameEnd == -1) return null;
        
        return line.substring(nameStart, nameEnd);
    }

    private String extractDurationAttribute(String line) {
        // Extract value from duration="..." attribute
        int durationStart = line.indexOf("duration=\"");
        if (durationStart == -1) return null;
        
        durationStart += 10; // Skip 'duration="'
        int durationEnd = line.indexOf("\"", durationStart);
        if (durationEnd == -1) return null;
        
        return line.substring(durationStart, durationEnd);
    }

    private String cleanSongName(String songName) {
        // Remove file extension
        if (songName.endsWith(".mp3")) {
            songName = songName.substring(0, songName.length() - 4);
        }
        
        // Decode common HTML entities
        songName = songName.replace("&#39;", "'")
                          .replace("&amp;", "&")
                          .replace("&lt;", "<")
                          .replace("&gt;", ">")
                          .replace("&quot;", "\"");
        
        // Trim whitespace
        return songName.trim();
    }

    private String formatDuration(String durationSeconds) {
        try {
            int seconds = Integer.parseInt(durationSeconds);
            int minutes = seconds / 60;
            int remainingSeconds = seconds % 60;
            return String.format("%d:%02d", minutes, remainingSeconds);
        } catch (NumberFormatException e) {
            return durationSeconds;
        }
    }

    private String extractTagValue(String line, String tagName) {
        String startTag = "<" + tagName + ">";
        String endTag = "</" + tagName + ">";
        
        int startIndex = line.indexOf(startTag);
        int endIndex = line.indexOf(endTag);
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return line.substring(startIndex + startTag.length(), endIndex).trim();
        }
        
        return null;
    }

    private List<Song> createFallbackSongs() {
        // Return a sample of popular FFT Battleground tracks
        List<Song> fallbackSongs = new ArrayList<>();
        fallbackSongs.add(new Song("Final Fantasy Tactics - Ovelia's Theme", "Final Fantasy Tactics", "OST", "3:24"));
        fallbackSongs.add(new Song("Final Fantasy Tactics - Decisive Battle", "Final Fantasy Tactics", "OST", "4:12"));
        fallbackSongs.add(new Song("Final Fantasy Tactics - Antipyretic", "Final Fantasy Tactics", "OST", "2:45"));
        fallbackSongs.add(new Song("Wild Arms - Windbreaker", "Wild Arms", "OST", "3:15"));
        fallbackSongs.add(new Song("Chrono Trigger - Frog's Theme", "Chrono Trigger", "OST", "2:55"));
        fallbackSongs.add(new Song("Secret of Mana - Fear of the Heavens", "Secret of Mana", "OST", "3:33"));
        fallbackSongs.add(new Song("Final Fantasy VI - Dancing Mad", "Final Fantasy VI", "OST", "17:38"));
        fallbackSongs.add(new Song("Xenogears - Flight", "Xenogears", "OST", "4:22"));
        fallbackSongs.add(new Song("Final Fantasy VII - One-Winged Angel", "Final Fantasy VII", "OST", "7:04"));
        fallbackSongs.add(new Song("Terranigma - Underworld", "Terranigma", "OST", "2:48"));
        
        logger.info("Using fallback playlist with {} songs", fallbackSongs.size());
        return fallbackSongs;
    }

    /**
     * Get total number of songs in the playlist
     */
    public int getSongCount() {
        return fetchSongs().size();
    }
}