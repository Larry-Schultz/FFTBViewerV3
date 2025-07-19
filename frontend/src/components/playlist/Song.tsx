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

  const formatDate = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Unknown';
    try {
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return 'Unknown';
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch (error) {
      return 'Unknown';
    }
  };

  const formatLastPlayed = (count: number, lastPlayed?: string | null): string => {
    if (count === 0) return 'Never';
    if (lastPlayed) {
      return formatDate(lastPlayed);
    }
    return 'Never';
  };

  return (
    <tr className="song-row">
      <td className="song-number">{index + 1}</td>
      <td className="song-title">{song.title}</td>
      <td className="song-duration">{formatDuration(song.duration)}</td>
      <td className="song-plays">{formatPlayCount(song.occurrence)}</td>
      <td className="song-added">{formatDate(song.createdAt)}</td>
      <td className="song-last-played">{formatLastPlayed(song.occurrence, song.updatedAt)}</td>
    </tr>
  );
};

export default Song;