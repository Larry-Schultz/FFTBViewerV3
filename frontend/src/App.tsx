import React from 'react';
import Header from './components/Header';
import { ChatView } from './components/chat';
import { PlaylistView } from './components/playlist';
import { ViewType } from './types';
import './styles/main.css';

function App() {
  // Detect initial view based on current URL path
  const getInitialView = (): ViewType => {
    const path = window.location.pathname;
    if (path === '/music' || path === '/playlist') {
      return 'playlist';
    }
    return 'chat'; // Default for '/', '/chat', or any other path
  };

  const [currentView, setCurrentView] = React.useState<ViewType>(getInitialView());

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