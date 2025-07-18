import React from 'react';
import Header from './components/Header';
import ChatView from './components/ChatView';
import './styles/main.css';

function App() {
  const [currentView, setCurrentView] = React.useState('chat');

  return (
    <div className="app">
      <Header currentView={currentView} onViewChange={setCurrentView} />
      <main className="main-content">
        {currentView === 'chat' && <ChatView />}
        {currentView === 'playlist' && (
          <div className="loading">Music playlist view coming soon...</div>
        )}
      </main>
    </div>
  );
}

export default App;