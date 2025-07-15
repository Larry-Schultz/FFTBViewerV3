package com.twitchchat.controller;

import com.twitchchat.service.ChatMessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Web controller for serving the chat viewer page
 */
@Controller
public class WebController {

    @Autowired
    private ChatMessageService chatMessageService;

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
}