// WebSocket connection and chat functionality
class TwitchChatClient {
    constructor() {
        this.stompClient = null;
        this.messageCount = parseInt(document.getElementById('message-count').textContent) || 0;
        this.maxMessages = 50;
        this.init();
    }

    init() {
        this.connectWebSocket();
        this.setupEventListeners();
    }

    connectWebSocket() {
        console.log('Connecting to WebSocket...');
        
        // Create SockJS connection
        const socket = new SockJS('/ws');
        this.stompClient = Stomp.over(socket);
        
        // Disable debug output
        this.stompClient.debug = null;
        
        // Connect to WebSocket
        this.stompClient.connect({}, (frame) => {
            console.log('Connected to WebSocket:', frame);
            this.updateConnectionStatus(true);
            
            // Subscribe to chat messages
            this.stompClient.subscribe('/topic/messages', (message) => {
                this.handleNewMessage(JSON.parse(message.body));
            });
            
        }, (error) => {
            console.error('WebSocket connection error:', error);
            this.updateConnectionStatus(false);
            
            // Attempt to reconnect after 5 seconds
            setTimeout(() => {
                console.log('Attempting to reconnect...');
                this.connectWebSocket();
            }, 5000);
        });
    }

    handleNewMessage(chatMessage) {
        console.log('New message received:', chatMessage);
        
        // Create message element
        const messageElement = this.createMessageElement(chatMessage);
        
        // Add to chat container
        const chatMessages = document.getElementById('chat-messages');
        chatMessages.appendChild(messageElement);
        
        // Maintain 50 message limit
        this.maintainMessageLimit();
        
        // Update message count
        this.updateMessageCount();
        
        // Auto-scroll to bottom
        this.scrollToBottom();
    }

    createMessageElement(chatMessage) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message';
        
        messageDiv.innerHTML = `
            <span class="timestamp">${chatMessage.timestamp}</span>
            <span class="username">${this.escapeHtml(chatMessage.username)}</span>:
            <span class="content">${this.escapeHtml(chatMessage.message)}</span>
        `;
        
        return messageDiv;
    }

    maintainMessageLimit() {
        const chatMessages = document.getElementById('chat-messages');
        const messages = chatMessages.querySelectorAll('.message');
        
        while (messages.length > this.maxMessages) {
            chatMessages.removeChild(messages[0]);
        }
    }

    updateMessageCount() {
        this.messageCount++;
        document.getElementById('message-count').textContent = this.messageCount;
    }

    updateConnectionStatus(connected) {
        const statusElement = document.getElementById('connection-status');
        if (connected) {
            statusElement.textContent = 'Connected';
            statusElement.className = 'status-connected';
        } else {
            statusElement.textContent = 'Disconnected';
            statusElement.className = 'status-disconnected';
        }
    }

    scrollToBottom() {
        const chatMessages = document.getElementById('chat-messages');
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    setupEventListeners() {
        // Auto-scroll to bottom on page load
        window.addEventListener('load', () => {
            this.scrollToBottom();
        });
        
        // Handle page visibility changes
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && this.stompClient && !this.stompClient.connected) {
                this.connectWebSocket();
            }
        });
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    disconnect() {
        if (this.stompClient && this.stompClient.connected) {
            this.stompClient.disconnect();
            console.log('Disconnected from WebSocket');
        }
    }
}

// Initialize chat client when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const chatClient = new TwitchChatClient();
    
    // Cleanup on page unload
    window.addEventListener('beforeunload', () => {
        chatClient.disconnect();
    });
});

console.log('Twitch Chat Client loaded successfully');