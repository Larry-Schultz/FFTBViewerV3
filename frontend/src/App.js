import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import PlaylistView from './components/PlaylistView';
import ChatView from './components/ChatView';
import { PlaylistService } from './services/PlaylistService';
import { ChatService } from './services/ChatService';

function App() {
  const [currentView, setCurrentView] = useState('playlist');
  const [playlistData, setPlaylistData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadInitialData = async () => {
      try {
        setLoading(true);
        if (currentView === 'playlist') {
          const data = await PlaylistService.getSongs(0, 50, 'title', 'asc');
          setPlaylistData(data);
        }
      } catch (error) {
        console.error('Error loading data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadInitialData();
  }, [currentView]);

  return (
    <div className="app">
      <Header currentView={currentView} onViewChange={setCurrentView} />
      <main className="main-content">
        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <>
            {currentView === 'playlist' && (
              <PlaylistView 
                data={playlistData} 
                onDataChange={setPlaylistData}
              />
            )}
            {currentView === 'chat' && <ChatView />}
          </>
        )}
      </main>
    </div>
  );
}

export default App;