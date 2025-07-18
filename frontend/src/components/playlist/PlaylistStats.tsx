import React, { useEffect, useState } from 'react';

interface PlaylistStatsProps {
  totalSongs: number;
  showingSongs: number;
  latestSongTime?: string | null;
}

const PlaylistStats: React.FC<PlaylistStatsProps> = ({ totalSongs, showingSongs, latestSongTime }) => {
  const [formattedTime, setFormattedTime] = useState<string>('Loading...');

  useEffect(() => {
    if (latestSongTime) {
      try {
        const date = new Date(latestSongTime);
        const dateOptions: Intl.DateTimeFormatOptions = {
          year: 'numeric',
          month: 'short',
          day: 'numeric'
        };
        const timeOptions: Intl.DateTimeFormatOptions = {
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
    } else {
      setFormattedTime('Never');
    }
  }, [latestSongTime]);

  return (
    <div className="playlist-stats">
      <div className="stat-item">
        <div className="stat-label">Total Tracks</div>
        <div className="stat-value">{(totalSongs || 0).toLocaleString()}</div>
      </div>
      <div className="stat-item">
        <div className="stat-label">Showing</div>
        <div className="stat-value">{showingSongs || 0}</div>
      </div>
      {latestSongTime && (
        <div className="stat-item">
          <div className="stat-label">Last Updated</div>
          <div className="stat-value">{formattedTime}</div>
        </div>
      )}
    </div>
  );
};

export default PlaylistStats;