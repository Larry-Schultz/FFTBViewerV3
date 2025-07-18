import React, { useState, useEffect, useRef } from 'react';
import { ChatService } from '../services/ChatService';

function ChatView() {
  const [messages, setMessages] = useState([]);
  const [connected, setConnected] = useState(false);
  const messagesEndRef = useRef(null);

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

  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString();
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
        {messages.map((message, index) => (
          <div key={index} className="chat-message">
            <span className="message-time">
              {formatTimestamp(message.timestamp)}
            </span>
            <span className="message-username" style={{ color: message.userColor || '#ffffff' }}>
              {message.username}:
            </span>
            <span className="message-text">
              {message.message}
            </span>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      
      {messages.length === 0 && (
        <div className="no-messages">
          {connected ? 'Waiting for messages...' : 'Connecting to chat...'}
        </div>
      )}
    </div>
  );
}

export default ChatView;