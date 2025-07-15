package com.twitchchat.repository;

import com.twitchchat.model.Song;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Song entities with custom queries for playlist management
 */
@Repository
public interface SongRepository extends JpaRepository<Song, Long> {
    
    /**
     * Find song by exact title match
     */
    Optional<Song> findByTitle(String title);
    
    /**
     * Check if a song exists by title
     */
    boolean existsByTitle(String title);
    
    /**
     * Search songs by title containing search term (case insensitive)
     */
    @Query("SELECT s FROM Song s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) ORDER BY s.title")
    List<Song> findByTitleContainingIgnoreCase(String searchTerm);
    
    /**
     * Search songs by title containing search term (case insensitive) with pagination
     */
    @Query("SELECT s FROM Song s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Song> findByTitleContainingIgnoreCase(String searchTerm, Pageable pageable);
    
    /**
     * Get all songs ordered by title
     */
    List<Song> findAllByOrderByTitleAsc();
    
    /**
     * Get all songs ordered by duration
     */
    List<Song> findAllByOrderByDurationAsc();
    
    /**
     * Count total songs in database
     */
    @Query("SELECT COUNT(s) FROM Song s")
    long countAllSongs();
    
    /**
     * Get all song titles for duplicate checking (more efficient than loading full objects)
     */
    @Query("SELECT s.title FROM Song s WHERE s.title IS NOT NULL")
    List<String> findAllTitles();
    
    /**
     * Get recently added songs (for sync verification)
     */
    List<Song> findTop10ByOrderByCreatedAtDesc();
    
    /**
     * Get most played songs by occurrence count
     */
    List<Song> findTop20ByOrderByOccurrenceDesc();
    
    /**
     * Get songs that have been played at least once
     */
    List<Song> findByOccurrenceGreaterThanOrderByOccurrenceDesc(int occurrence);
}