import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';
import { ChatMessage } from '../types';

export class ChatService {
  private stompClient: any = null;
  private connected: boolean = false;
  private subscription: any = null;

  connect(
    onMessage: (message: ChatMessage) => void, 
    onConnect?: () => void, 
    onDisconnect?: () => void
  ): void {
    const socket = new SockJS('/ws');
    this.stompClient = Stomp.over(socket);

    this.stompClient.connect({}, () => {
      this.connected = true;
      onConnect && onConnect();

      if (this.stompClient) {
        this.subscription = this.stompClient.subscribe('/topic/messages', (message: any) => {
          if (onMessage && message.body) {
            try {
              const chatMessage: ChatMessage = JSON.parse(message.body);
              onMessage(chatMessage);
            } catch (error) {
              console.error('Error parsing chat message:', error);
            }
          }
        });
      }
    }, (error: any) => {
      this.connected = false;
      console.error('WebSocket connection error:', error);
      onDisconnect && onDisconnect();
    });
  }

  disconnect(): void {
    if (this.subscription) {
      this.subscription.unsubscribe();
      this.subscription = null;
    }
    if (this.stompClient && this.connected) {
      this.stompClient.disconnect();
      this.connected = false;
    }
  }
}