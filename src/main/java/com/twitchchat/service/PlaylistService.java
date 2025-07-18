package com.twitchchat.service;

import com.twitchchat.model.Song;
import com.twitchchat.repository.SongRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service to manage playlist data from the database
 */
@Service
public class PlaylistService {
    private static final Logger logger = LoggerFactory.getLogger(PlaylistService.class);
    
    private final SongRepository songRepository;
    
    // Constructor injection
    public PlaylistService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

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
     * Get paginated songs with occurrence and creation date
     */
    public Page<Song> fetchSongsPaginated(int page, int size, String sortBy, String sortDirection) {
        try {
            // Special handling for updatedAt to show songs with timestamps first
            if ("updatedAt".equals(sortBy)) {
                return fetchSongsWithUpdatedAtSort(page, size, sortDirection);
            }
            
            Sort.Direction direction = "desc".equalsIgnoreCase(sortDirection) ? Sort.Direction.DESC : Sort.Direction.ASC;
            Sort sort = Sort.by(direction, sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            
            Page<Song> songs = songRepository.findAll(pageable);
            logger.info("Retrieved page {} of {} songs (size: {}, sort: {} {})", 
                       page + 1, songs.getTotalPages(), size, sortBy, sortDirection);
            return songs;
        } catch (Exception e) {
            logger.error("Error retrieving paginated songs", e);
            return Page.empty();
        }
    }

    /**
     * Special method for sorting by updatedAt with proper NULL handling
     */
    private Page<Song> fetchSongsWithUpdatedAtSort(int page, int size, String sortDirection) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            boolean descending = "desc".equalsIgnoreCase(sortDirection);
            
            Page<Song> songs;
            if (descending) {
                // For DESC: Show songs with updatedAt first (NULLS LAST)
                songs = songRepository.findAllOrderByUpdatedAtDescNullsLast(pageable);
            } else {
                // For ASC: Show songs with updatedAt first (NULLS LAST)  
                songs = songRepository.findAllOrderByUpdatedAtAscNullsLast(pageable);
            }
            
            logger.info("Retrieved page {} of {} songs sorted by updatedAt {} (NULLS LAST)", 
                       page + 1, songs.getTotalPages(), sortDirection);
            return songs;
        } catch (Exception e) {
            logger.error("Error retrieving songs sorted by updatedAt", e);
            return Page.empty();
        }
    }

    /**
     * Search songs with pagination
     */
    public Page<Song> searchSongsPaginated(String searchTerm, int page, int size, String sortBy, String sortDirection) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return fetchSongsPaginated(page, size, sortBy, sortDirection);
        }
        
        try {
            // Special handling for updatedAt to show songs with timestamps first
            if ("updatedAt".equals(sortBy)) {
                return searchSongsWithUpdatedAtSort(searchTerm, page, size, sortDirection);
            }
            
            Sort.Direction direction = "desc".equalsIgnoreCase(sortDirection) ? Sort.Direction.DESC : Sort.Direction.ASC;
            Sort sort = Sort.by(direction, sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            
            Page<Song> songs = songRepository.findByTitleContainingIgnoreCase(searchTerm.trim(), pageable);
            logger.info("Found page {} of {} songs matching search term: '{}' (size: {}, sort: {} {})", 
                       page + 1, songs.getTotalPages(), searchTerm, size, sortBy, sortDirection);
            return songs;
        } catch (Exception e) {
            logger.error("Error searching songs with term: '{}'", searchTerm, e);
            return Page.empty();
        }
    }

    /**
     * Search songs with updatedAt sorting and proper NULL handling
     */
    private Page<Song> searchSongsWithUpdatedAtSort(String searchTerm, int page, int size, String sortDirection) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            boolean descending = "desc".equalsIgnoreCase(sortDirection);
            
            Page<Song> songs;
            if (descending) {
                songs = songRepository.findByTitleContainingIgnoreCaseOrderByUpdatedAtDescNullsLast(searchTerm.trim(), pageable);
            } else {
                songs = songRepository.findByTitleContainingIgnoreCaseOrderByUpdatedAtAscNullsLast(searchTerm.trim(), pageable);
            }
            
            logger.info("Found page {} of {} songs matching search term: '{}' sorted by updatedAt {} (NULLS LAST)", 
                       page + 1, songs.getTotalPages(), searchTerm, sortDirection);
            return songs;
        } catch (Exception e) {
            logger.error("Error searching songs with term: '{}' sorted by updatedAt", searchTerm, e);
            return Page.empty();
        }
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
    
    /**
     * Get the timestamp when the latest song was added to the playlist
     */
    public LocalDateTime getLatestSongAddedTime() {
        try {
            return songRepository.findLatestSongAddedTime();
        } catch (Exception e) {
            logger.error("Error retrieving latest song added time", e);
            return null;
        }
    }
}