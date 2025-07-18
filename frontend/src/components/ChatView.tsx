import React, { useState, useEffect, useRef } from 'react';
import { ChatService } from '../services/ChatService';
import { ChatMessage } from '../types';

function ChatView() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [connected, setConnected] = useState<boolean>(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const chatService = new ChatService();
    
    chatService.connect(
      (message) => {
        setMessages(prev => [...prev.slice(-49), message]); // Keep last 50 messages
      },
      () => setConnected(true),
      () => setConnected(false)
    );

    return () => {
      chatService.disconnect();
    };
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const formatTimestamp = (timestamp: string): string => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('en-US', { 
      hour12: false, 
      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit' 
    });
  };

  return (
    <div className="chat-view">
      <div className="chat-header">
        <h2>Live Chat from FFT Battleground</h2>
        <div className={`connection-status ${connected ? 'connected' : 'disconnected'}`}>
          {connected ? '🟢 Connected' : '🔴 Disconnected'}
        </div>
      </div>
      
      <div className="chat-messages">
        {messages.length === 0 ? (
          <div className="no-messages">
            {connected ? 'Waiting for messages...' : 'Connecting to chat...'}
          </div>
        ) : (
          messages.map((message, index) => (
            <div key={index} className="chat-message">
              {formatTimestamp(message.timestamp)}{message.username}: {message.message}
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>
    </div>
  );
}

export default ChatView;