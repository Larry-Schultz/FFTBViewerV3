import React from 'react';
import { ChatMessage as ChatMessageType } from '../../types';

interface ChatMessageProps {
  message: ChatMessageType;
}

function ChatMessage({ message }: ChatMessageProps) {
  const formatTimestamp = (timestamp: string): string => {
    if (!timestamp) return '';
    try {
      const date = new Date(timestamp);
      if (isNaN(date.getTime())) return '';
      return date.toLocaleTimeString('en-US', { 
        hour12: false, 
        hour: '2-digit', 
        minute: '2-digit', 
        second: '2-digit' 
      });
    } catch (error) {
      return '';
    }
  };

  return (
    <div className="chat-message">
      <span className="message-time">{formatTimestamp(message.timestamp)}</span>
      <span className="message-space"> </span>
      <span className="message-username">{message.username}</span>
      <span className="message-separator"> : </span>
      <span className="message-text">{message.message}</span>
    </div>
  );
}

export default ChatMessage;