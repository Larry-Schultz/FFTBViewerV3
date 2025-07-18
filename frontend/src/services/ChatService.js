import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

export class ChatService {
  constructor() {
    this.stompClient = null;
    this.connected = false;
  }

  connect(onMessage, onConnect, onDisconnect) {
    const socket = new SockJS('/ws');
    this.stompClient = Stomp.over(socket);

    this.stompClient.connect({}, () => {
      this.connected = true;
      onConnect && onConnect();

      if (this.stompClient) {
        this.stompClient.subscribe('/topic/messages', (message) => {
          if (onMessage && message.body) {
            try {
              const chatMessage = JSON.parse(message.body);
              onMessage(chatMessage);
            } catch (error) {
              console.error('Error parsing chat message:', error);
            }
          }
        });
      }
    }, (error) => {
      this.connected = false;
      console.error('WebSocket connection error:', error);
      onDisconnect && onDisconnect();
    });
  }

  disconnect() {
    if (this.stompClient && this.connected) {
      this.stompClient.disconnect();
      this.connected = false;
    }
  }
}