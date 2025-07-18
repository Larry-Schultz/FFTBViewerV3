import React from 'react';
import Header from './components/Header';
import ChatView from './components/ChatView';
import PlaylistView from './components/PlaylistView';
import './styles/main.css';

function App() {
  const [currentView, setCurrentView] = React.useState('chat');

  return (
    <div className="app">
      <Header currentView={currentView} onViewChange={setCurrentView} />
      <main className="main-content">
        <div className="container">
          {currentView === 'chat' && <ChatView />}
          {currentView === 'playlist' && <PlaylistView />}
        </div>
      </main>
    </div>
  );
}

export default App;