import React from 'react';

function SongTable({ songs, sortBy, sortDirection, onSort }) {
  const getSortIcon = (field) => {
    if (sortBy !== field) return '↕';
    return sortDirection === 'asc' ? '↑' : '↓';
  };

  const formatDuration = (duration) => {
    if (!duration || duration === '0:00') return '0:00';
    return duration;
  };

  const formatPlayCount = (count) => {
    return count > 0 ? count : 'Never';
  };

  return (
    <div className="song-table-container">
      <table className="song-table">
        <thead>
          <tr>
            <th 
              className="sortable" 
              onClick={() => onSort('title')}
            >
              Song Title {getSortIcon('title')}
            </th>
            <th 
              className="sortable" 
              onClick={() => onSort('duration')}
            >
              Duration {getSortIcon('duration')}
            </th>
            <th 
              className="sortable" 
              onClick={() => onSort('occurrence')}
            >
              Plays {getSortIcon('occurrence')}
            </th>
            <th 
              className="sortable" 
              onClick={() => onSort('createdAt')}
            >
              Added {getSortIcon('createdAt')}
            </th>
          </tr>
        </thead>
        <tbody>
          {songs.map((song, index) => (
            <tr key={song.id || index} className="song-row">
              <td className="song-title">{song.title}</td>
              <td className="song-duration">{formatDuration(song.duration)}</td>
              <td className="song-plays">{formatPlayCount(song.occurrence)}</td>
              <td className="song-added">
                {song.createdAt ? new Date(song.createdAt).toLocaleDateString() : 'Unknown'}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {songs.length === 0 && (
        <div className="no-results">
          No songs found. Try adjusting your search terms.
        </div>
      )}
    </div>
  );
}

export default SongTable;