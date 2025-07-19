package com.twitchchat.service;

import com.twitchchat.config.TrackPlayProperties;
import com.twitchchat.event.TrackPlayEvent;
import com.twitchchat.model.Song;
import com.twitchchat.model.TrackPlay;
import com.twitchchat.repository.SongRepository;
import com.twitchchat.repository.TrackPlayRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

/**
 * Service to track song plays from TrackPlayEvent and update occurrence counts
 */
@Service
public class SongPlayTracker {
    private static final Logger logger = LoggerFactory.getLogger(SongPlayTracker.class);
    
    @Autowired
    private SongRepository songRepository;
    
    @Autowired
    private TrackPlayRepository trackPlayRepository;
    
    @Autowired
    private TrackPlayProperties trackPlayProperties;
    
    /**
     * Asynchronously track a song play and update its occurrence count
     * @param event The TrackPlayEvent containing song information
     * @return CompletableFuture<Boolean> indicating if the song was found and updated
     */
    @Async
    public CompletableFuture<Boolean> trackSongPlayAsync(TrackPlayEvent event) {
        try {
            // Check if track play updates are enabled
            if (!trackPlayProperties.isEnabled()) {
                logger.info("Track play updates are disabled, skipping database update for: {}", event.getSongTitle());
                return CompletableFuture.completedFuture(false);
            }
            
            // Check if we're in log-only mode
            if (trackPlayProperties.isLogOnly()) {
                logger.info("LOG-ONLY MODE: Would track play for '{}' ({}s)", 
                           event.getSongTitle(), event.getDurationSeconds());
                return CompletableFuture.completedFuture(true);
            }
            
            // Full database update mode
            boolean result = trackSongPlay(event.getSongTitle());
            return CompletableFuture.completedFuture(result);
        } catch (Exception e) {
            logger.error("Error tracking song play asynchronously: {}", e.getMessage(), e);
            return CompletableFuture.completedFuture(false);
        }
    }
    
    /**
     * Track a song play and update its occurrence count
     * @param songTitle The title of the song that was played
     * @return true if the song was found and updated, false otherwise
     */
    private boolean trackSongPlay(String songTitle) {
        Optional<Song> songOpt = songRepository.findByTitle(songTitle);
        
        if (songOpt.isPresent()) {
            Song song = songOpt.get();
            
            // Update song occurrence count and timestamp only if enabled
            if (trackPlayProperties.isUpdateOccurrences()) {
                song.setOccurrence(song.getOccurrence() + 1);
                song.setUpdatedAt(LocalDateTime.now());
                songRepository.save(song);
                logger.debug("Updated occurrence count for '{}' - occurrence now: {}", songTitle, song.getOccurrence());
            }
            
            // Create and save track play record if enabled
            TrackPlay trackPlay = null;
            if (trackPlayProperties.isRecordTrackPlays()) {
                trackPlay = new TrackPlay(song);
                trackPlayRepository.save(trackPlay);
                logger.debug("Created TrackPlay record for '{}' - TrackPlay ID: {}", songTitle, trackPlay.getId());
            }
            
            logger.info("Tracked play for '{}' - occurrence updates: {}, TrackPlay recording: {}", 
                       songTitle, trackPlayProperties.isUpdateOccurrences(), trackPlayProperties.isRecordTrackPlays());
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