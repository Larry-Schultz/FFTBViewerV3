package com.twitchchat.service;

import com.twitchchat.event.TrackPlayEvent;
import com.twitchchat.model.Song;
import com.twitchchat.repository.SongRepository;
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
    
    /**
     * Asynchronously track a song play and update its occurrence count
     * @param event The TrackPlayEvent containing song information
     * @return CompletableFuture<Boolean> indicating if the song was found and updated
     */
    @Async
    public CompletableFuture<Boolean> trackSongPlayAsync(TrackPlayEvent event) {
        try {
            boolean result = trackSongPlay(event.getSongTitle(), event.getDurationSeconds());
            return CompletableFuture.completedFuture(result);
        } catch (Exception e) {
            logger.error("Error tracking song play asynchronously: {}", e.getMessage(), e);
            return CompletableFuture.completedFuture(false);
        }
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