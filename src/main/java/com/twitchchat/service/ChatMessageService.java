package com.twitchchat.service;

import com.twitchchat.model.ChatMessage;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Service to manage chat messages and maintain the last 50 messages
 */
@Service
public class ChatMessageService {
    private static final int MAX_MESSAGES = 50;
    private final List<ChatMessage> messages = Collections.synchronizedList(new ArrayList<>());

    /**
     * Add a new chat message and maintain the 50 message limit
     */
    public void addMessage(ChatMessage message) {
        synchronized (messages) {
            messages.add(message);
            
            // Keep only the last 50 messages
            if (messages.size() > MAX_MESSAGES) {
                messages.remove(0);
            }
        }
    }

    /**
     * Get all stored messages (last 50)
     */
    public List<ChatMessage> getAllMessages() {
        synchronized (messages) {
            return new ArrayList<>(messages);
        }
    }

    /**
     * Get the count of stored messages
     */
    public int getMessageCount() {
        return messages.size();
    }
}