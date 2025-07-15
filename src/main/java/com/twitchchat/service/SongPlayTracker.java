package com.twitchchat.service;

import com.twitchchat.model.Song;
import com.twitchchat.repository.SongRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Service to track song plays from Twitch chat messages and update occurrence counts
 */
@Service
public class SongPlayTracker {
    private static final Logger logger = LoggerFactory.getLogger(SongPlayTracker.class);
    
    // Pattern to match "The track is now: Song Title. It will play for X seconds."
    private static final Pattern TRACK_PATTERN = Pattern.compile(
        "The track is now: (.+?)\\. It will play for (\\d+) seconds\\."
    );
    
    @Autowired
    private SongRepository songRepository;
    
    /**
     * Process a chat message to detect track announcements and update song occurrence
     * @param username The username of the chat message sender
     * @param message The chat message content
     * @return true if a track was detected and processed, false otherwise
     */
    public boolean processMessage(String username, String message) {
        // Only process messages from the bot account
        if (!"fftbattleground".equalsIgnoreCase(username)) {
            return false;
        }
        
        Matcher matcher = TRACK_PATTERN.matcher(message);
        if (matcher.matches()) {
            String songTitle = matcher.group(1);
            String durationStr = matcher.group(2);
            
            try {
                int durationSeconds = Integer.parseInt(durationStr);
                return trackSongPlay(songTitle, durationSeconds);
            } catch (NumberFormatException e) {
                logger.warn("Failed to parse duration '{}' for song '{}'", durationStr, songTitle);
            }
        }
        
        return false;
    }
    
    /**
     * Track a song play and update its occurrence count
     * @param songTitle The title of the song that was played
     * @param durationSeconds The duration of the song in seconds
     * @return true if the song was found and updated, false otherwise
     */
    private boolean trackSongPlay(String songTitle, int durationSeconds) {
        Optional<Song> songOpt = songRepository.findByTitle(songTitle);
        
        if (songOpt.isPresent()) {
            Song song = songOpt.get();
            song.setOccurrence(song.getOccurrence() + 1);
            song.setUpdatedAt(LocalDateTime.now());
            songRepository.save(song);
            
            logger.info("Tracked play for '{}' ({}s) - occurrence now: {}", 
                       songTitle, durationSeconds, song.getOccurrence());
            return true;
        } else {
            logger.warn("Song '{}' not found in database, cannot track play", songTitle);
            return false;
        }
    }
    
    /**
     * Get the total number of tracked plays across all songs
     * @return The total play count
     */
    public long getTotalPlays() {
        return songRepository.findAll().stream()
            .mapToLong(song -> song.getOccurrence())
            .sum();
    }
    
    /**
     * Get the number of unique songs that have been played at least once
     * @return The count of played songs
     */
    public long getPlayedSongsCount() {
        return songRepository.findAll().stream()
            .filter(song -> song.getOccurrence() > 0)
            .count();
    }
}