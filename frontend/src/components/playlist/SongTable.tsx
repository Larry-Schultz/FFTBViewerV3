import React from 'react';
import { Song as SongType } from '../../types';
import Song from './Song';

interface SongTableProps {
  songs: SongType[];
  sortBy: string;
  sortDirection: 'asc' | 'desc';
  onSort: (field: string) => void;
}

const SongTable: React.FC<SongTableProps> = ({ songs, sortBy, sortDirection, onSort }) => {
  const getSortIcon = (field: string): string => {
    if (sortBy !== field) return '↕';
    return sortDirection === 'asc' ? '↑' : '↓';
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
            <th 
              className="sortable last-played-header" 
              onClick={() => onSort('updatedAt')}
            >
              Last Played {getSortIcon('updatedAt')}
            </th>
          </tr>
        </thead>
        <tbody>
          {songs.map((song, index) => (
            <Song key={song.id || index} song={song} index={index} />
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