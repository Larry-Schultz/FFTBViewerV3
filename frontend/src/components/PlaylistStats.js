import React, { useEffect, useState } from 'react';

function PlaylistStats({ totalSongs, showingSongs, latestSongTime }) {
  const [formattedTime, setFormattedTime] = useState('Loading...');

  useEffect(() => {
    if (latestSongTime) {
      try {
        const date = new Date(latestSongTime);
        const dateOptions = {
          year: 'numeric',
          month: 'short',
          day: 'numeric'
        };
        const timeOptions = {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false
        };
        const formattedDate = date.toLocaleDateString('en-US', dateOptions);
        const formattedTimeStr = date.toLocaleTimeString('en-US', timeOptions);
        setFormattedTime(`${formattedDate} ${formattedTimeStr}`);
      } catch (error) {
        console.error('Error formatting timestamp:', error);
        setFormattedTime('Unknown');
      }
    }
  }, [latestSongTime]);

  return (
    <div className="playlist-stats">
      <div className="stat-card">
        <h3>Total Tracks</h3>
        <span className="stat-number">{totalSongs}</span>
      </div>
      <div className="stat-card">
        <h3>Showing</h3>
        <span className="stat-number">{showingSongs}</span>
      </div>
      {latestSongTime && (
        <div className="stat-card">
          <h3>Last Updated</h3>
          <span className="stat-text">{formattedTime}</span>
        </div>
      )}
    </div>
  );
}

export default PlaylistStats;