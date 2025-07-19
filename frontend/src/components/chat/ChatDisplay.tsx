import React, { useEffect, useRef } from 'react';
import ChatMessage from './ChatMessage';
import { ChatMessage as ChatMessageType } from '../../types';
const styles = require('../../styles/ChatView.module.css');

interface ChatDisplayProps {
  messages: ChatMessageType[];
  connected: boolean;
}

function ChatDisplay({ messages, connected }: ChatDisplayProps) {
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className={styles.messagesContainer}>
      <div className={styles.messagesList}>
        {messages.length === 0 ? (
          <div className={styles.loading}>
            {connected ? 'Waiting for messages...' : 'Connecting to chat...'}
          </div>
        ) : (
          messages.map((message, index) => (
            <ChatMessage key={index} message={message} />
          ))
        )}
        <div ref={messagesEndRef} />
      </div>
    </div>
  );
}

export default ChatDisplay;