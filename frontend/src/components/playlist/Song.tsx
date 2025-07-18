import React from 'react';
import { Song as SongType } from '../../types';

interface SongProps {
  song: SongType;
  index: number;
}

const Song: React.FC<SongProps> = ({ song, index }) => {
  const formatDuration = (duration: string): string => {
    if (!duration || duration === '0:00') return '0:00';
    return duration;
  };

  const formatPlayCount = (count: number): string => {
    return count > 0 ? count.toString() : 'Never';
  };

  const formatDate = (dateString: string | null): string => {
    if (!dateString) return 'Unknown';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch (error) {
      return 'Unknown';
    }
  };

  const formatLastPlayed = (count: number, lastPlayed?: string): string => {
    if (count === 0) return 'Never';
    if (lastPlayed) {
      return formatDate(lastPlayed);
    }
    return 'Unknown';
  };

  return (
    <tr className="song-row">
      <td className="song-number">{index + 1}</td>
      <td className="song-title">{song.title}</td>
      <td className="song-duration">{formatDuration(song.duration)}</td>
      <td className="song-plays">{formatPlayCount(song.occurrence)}</td>
      <td className="song-added">{formatDate(song.createdAt)}</td>
      <td className="song-last-played">{formatLastPlayed(song.occurrence, song.lastPlayed)}</td>
    </tr>
  );
};

export default Song;