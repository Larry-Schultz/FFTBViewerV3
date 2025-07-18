import React, { useState, useEffect } from 'react';
import ChatDisplay from './ChatDisplay';
import { ChatService } from '../../services/ChatService';
import { ChatMessage } from '../../types';

function ChatView() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [connected, setConnected] = useState<boolean>(false);

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

  return (
    <div className="chat-view">
      <div className="chat-header">
        <h2>Live Chat from FFT Battleground</h2>
        <div className={`connection-status ${connected ? 'connected' : 'disconnected'}`}>
          {connected ? '🟢 Connected' : '🔴 Disconnected'}
        </div>
      </div>
      
      <ChatDisplay messages={messages} connected={connected} />
    </div>
  );
}

export default ChatView;