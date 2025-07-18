import React from 'react';
import { Song } from '../../types';

interface SongTableProps {
  songs: Song[];
  sortBy: string;
  sortDirection: 'asc' | 'desc';
  onSort: (field: string) => void;
}

const SongTable: React.FC<SongTableProps> = ({ songs, sortBy, sortDirection, onSort }) => {
  const getSortIcon = (field: string): string => {
    if (sortBy !== field) return '↕';
    return sortDirection === 'asc' ? '↑' : '↓';
  };

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
    <div className="song-table-container">
      <table className="song-table">
        <thead>
          <tr>
            <th className="song-number-header">#</th>
            <th 
              className="sortable song-title-header" 
              onClick={() => onSort('title')}
            >
              Song Title {getSortIcon('title')}
            </th>
            <th 
              className="sortable duration-header" 
              onClick={() => onSort('duration')}
            >
              Duration {getSortIcon('duration')}
            </th>
            <th 
              className="sortable plays-header" 
              onClick={() => onSort('occurrence')}
            >
              Plays {getSortIcon('occurrence')}
            </th>
            <th 
              className="sortable date-header" 
              onClick={() => onSort('createdAt')}
            >
              Added Date {getSortIcon('createdAt')}
            </th>
            <th className="last-played-header">
              Last Played
            </th>
          </tr>
        </thead>
        <tbody>
          {songs.map((song, index) => (
            <tr key={song.id || index} className="song-row">
              <td className="song-number">{index + 1}</td>
              <td className="song-title">{song.title}</td>
              <td className="song-duration">{formatDuration(song.duration)}</td>
              <td className="song-plays">{formatPlayCount(song.occurrence)}</td>
              <td className="song-added">{formatDate(song.createdAt)}</td>
              <td className="song-last-played">{formatLastPlayed(song.occurrence, song.lastPlayed)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      
      {songs.length === 0 && (
        <div className="no-songs">
          No songs found matching your search criteria.
        </div>
      )}
    </div>
  );
};

export default SongTable;