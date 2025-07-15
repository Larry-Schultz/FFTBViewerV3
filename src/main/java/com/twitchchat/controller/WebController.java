package com.twitchchat.controller;

import com.twitchchat.model.Song;
import com.twitchchat.service.ChatMessageService;
import com.twitchchat.service.PlaylistService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Collections;
import java.util.List;

/**
 * Web controller for serving the chat viewer and playlist pages
 */
@Controller
public class WebController {
    private static final Logger logger = LoggerFactory.getLogger(WebController.class);

    @Autowired
    private ChatMessageService chatMessageService;

    @Autowired
    private PlaylistService playlistService;

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("messages", chatMessageService.getAllMessages());
        model.addAttribute("messageCount", chatMessageService.getMessageCount());
        return "index";
    }

    @GetMapping("/chat")
    public String chat() {
        return "chat";
    }

    @GetMapping("/playlist")
    public String playlist(@RequestParam(value = "search", required = false) String search, Model model) {
        try {
            List<Song> songs;
            if (search != null && !search.trim().isEmpty()) {
                songs = playlistService.searchSongs(search);
                model.addAttribute("searchTerm", search);
            } else {
                songs = playlistService.fetchSongs();
            }
            
            model.addAttribute("songs", songs);
            model.addAttribute("totalSongs", playlistService.getTotalSongCount());
            model.addAttribute("showingSongs", songs.size());
            model.addAttribute("isSearchResult", search != null && !search.trim().isEmpty());
            
            return "playlist";
        } catch (Exception e) {
            logger.error("Error loading playlist", e);
            model.addAttribute("error", "Unable to load playlist: " + e.getMessage());
            model.addAttribute("songs", Collections.emptyList());
            model.addAttribute("totalSongs", 0);
            model.addAttribute("showingSongs", 0);
            return "playlist";
        }
    }
}