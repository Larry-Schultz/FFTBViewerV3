package com.twitchchat.service;

import com.twitchchat.model.Song;
import com.twitchchat.repository.SongRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service to manage playlist data from the database
 */
@Service
public class PlaylistService {
    private static final Logger logger = LoggerFactory.getLogger(PlaylistService.class);
    
    @Autowired
    private SongRepository songRepository;

    /**
     * Get all songs from the database, ordered by title
     */
    public List<Song> fetchSongs() {
        try {
            List<Song> songs = songRepository.findAllByOrderByTitleAsc();
            logger.info("Retrieved {} songs from database", songs.size());
            return songs;
        } catch (Exception e) {
            logger.error("Error retrieving songs from database", e);
            return Collections.emptyList();
        }
    }

    /**
     * Search songs by title
     */
    public List<Song> searchSongs(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return fetchSongs();
        }
        
        try {
            List<Song> songs = songRepository.findByTitleContainingIgnoreCase(searchTerm.trim());
            logger.info("Found {} songs matching search term: '{}'", songs.size(), searchTerm);
            return songs;
        } catch (Exception e) {
            logger.error("Error searching songs with term: '{}'", searchTerm, e);
            return Collections.emptyList();
        }
    }

    /**
     * Get songs sorted by duration
     */
    public List<Song> fetchSongsSortedByDuration() {
        try {
            List<Song> songs = songRepository.findAllByOrderByDurationAsc();
            logger.info("Retrieved {} songs sorted by duration", songs.size());
            return songs;
        } catch (Exception e) {
            logger.error("Error retrieving songs sorted by duration", e);
            return Collections.emptyList();
        }
    }

    /**
     * Get total song count
     */
    public long getTotalSongCount() {
        return songRepository.countAllSongs();
    }

    /**
     * Get songs with titles only (simplified for display)
     */
    public List<String> getSongTitles() {
        try {
            return songRepository.findAllByOrderByTitleAsc()
                    .stream()
                    .map(Song::getTitle)
                    .filter(title -> title != null && !title.trim().isEmpty())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error retrieving song titles", e);
            return Collections.emptyList();
        }
    }

    /**
     * Check if playlist data is available
     */
    public boolean isPlaylistAvailable() {
        try {
            long count = songRepository.countAllSongs();
            return count > 0;
        } catch (Exception e) {
            logger.error("Error checking playlist availability", e);
            return false;
        }
    }
}