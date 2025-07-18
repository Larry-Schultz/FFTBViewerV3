import React from 'react';
import { ViewType } from '../types';

interface HeaderProps {
  currentView: ViewType;
  onViewChange: (view: ViewType) => void;
}

function Header({ currentView, onViewChange }: HeaderProps) {
  return (
    <div className="header">
      <h1>FFT Battleground</h1>
      <div className="nav-buttons">
        <button 
          className={`nav-button ${currentView === 'chat' ? 'active' : ''}`}
          onClick={() => onViewChange('chat')}
        >
          Live Chat
        </button>
        <button 
          className={`nav-button ${currentView === 'playlist' ? 'active' : ''}`}
          onClick={() => onViewChange('playlist')}
        >
          Music Playlist
        </button>
      </div>
    </div>
  );
}

export default Header;