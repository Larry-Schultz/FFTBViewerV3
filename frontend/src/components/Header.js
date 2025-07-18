import React from 'react';

function Header({ currentView, onViewChange }) {
  return (
    <header className="header">
      <div className="header-container">
        <h1 className="header-title">
          <span className="header-icon">🎵</span>
          FFT Battleground
        </h1>
        <nav className="header-nav">
          <button 
            className={`nav-button ${currentView === 'playlist' ? 'active' : ''}`}
            onClick={() => onViewChange('playlist')}
          >
            Music Playlist
          </button>
          <button 
            className={`nav-button ${currentView === 'chat' ? 'active' : ''}`}
            onClick={() => onViewChange('chat')}
          >
            Live Chat
          </button>
        </nav>
      </div>
    </header>
  );
}

export default Header;