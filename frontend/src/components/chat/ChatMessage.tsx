import React from 'react';
import { ChatMessage as ChatMessageType } from '../../types';
const styles = require('../../styles/ChatView.module.css');

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
    <div className={styles.message}>
      <div className={styles.messageHeader}>
        <span className={styles.username}>{message.username}</span>
        <span className={styles.timestamp}>{formatTimestamp(message.timestamp)}</span>
      </div>
      <div className={styles.messageContent}>{message.message}</div>
    </div>
  );
}

export default ChatMessage;