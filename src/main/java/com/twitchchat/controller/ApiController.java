package com.twitchchat.controller;

import com.twitchchat.service.PlaylistSyncService;
import com.twitchchat.service.PlaylistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * REST API controller for playlist and sync management
 */
@RestController
@RequestMapping("/api")
public class ApiController {

    @Autowired
    private PlaylistService playlistService;

    @Autowired
    private PlaylistSyncService playlistSyncService;

    /**
     * Get playlist status and statistics
     */
    @GetMapping("/playlist/status")
    public ResponseEntity<Map<String, Object>> getPlaylistStatus() {
        Map<String, Object> status = new HashMap<>();
        
        long totalSongs = playlistService.getTotalSongCount();
        boolean isAvailable = playlistService.isPlaylistAvailable();
        
        status.put("totalSongs", totalSongs);
        status.put("isAvailable", isAvailable);
        status.put("status", isAvailable ? "ready" : "syncing");
        
        return ResponseEntity.ok(status);
    }

    /**
     * Force manual sync of playlist data
     */
    @PostMapping("/playlist/sync")
    public ResponseEntity<Map<String, String>> forceSync() {
        try {
            playlistSyncService.forceSyncPlaylist();
            
            Map<String, String> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Playlist sync initiated");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("status", "error");
            response.put("message", "Sync failed: " + e.getMessage());
            
            return ResponseEntity.status(500).body(response);
        }
    }
}