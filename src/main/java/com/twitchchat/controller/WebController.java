package com.twitchchat.controller;

import com.twitchchat.model.Song;
import com.twitchchat.service.ChatMessageService;
import com.twitchchat.service.PlaylistService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
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
    public String playlist(
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "50") int size,
            @RequestParam(value = "sortBy", defaultValue = "title") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "asc") String sortDirection,
            Model model) {
        try {
            // Validate page size limits
            if (size < 10) size = 10;
            if (size > 500) size = 500;
            
            Page<Song> songPage;
            if (search != null && !search.trim().isEmpty()) {
                songPage = playlistService.searchSongsPaginated(search, page, size, sortBy, sortDirection);
                model.addAttribute("searchTerm", search);
            } else {
                songPage = playlistService.fetchSongsPaginated(page, size, sortBy, sortDirection);
            }
            
            model.addAttribute("songs", songPage.getContent());
            model.addAttribute("totalSongs", songPage.getTotalElements());
            model.addAttribute("showingSongs", songPage.getContent().size());
            model.addAttribute("isSearchResult", search != null && !search.trim().isEmpty());
            
            // Pagination attributes
            model.addAttribute("currentPage", page);
            model.addAttribute("pageSize", size);
            model.addAttribute("totalPages", songPage.getTotalPages());
            model.addAttribute("hasNext", songPage.hasNext());
            model.addAttribute("hasPrevious", songPage.hasPrevious());
            model.addAttribute("sortBy", sortBy);
            model.addAttribute("sortDirection", sortDirection);
            
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