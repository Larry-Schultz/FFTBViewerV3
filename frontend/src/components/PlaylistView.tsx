import React, { useState, useEffect } from 'react';
import { PlaylistService } from '../services/PlaylistService';
import { PlaylistData } from '../types';

function PlaylistView() {
  const [playlistData, setPlaylistData] = useState<PlaylistData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [currentPage, setCurrentPage] = useState<number>(0);
  const [pageSize, setPageSize] = useState<number>(50);
  const [sortBy, setSortBy] = useState<string>('title');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');
  const [latestSongTime, setLatestSongTime] = useState<string | null>(null);
  const [debouncedSearchTerm, setDebouncedSearchTerm] = useState<string>('');

  // Debounce search term
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearchTerm(searchTerm);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  // Reset page when search term changes
  useEffect(() => {
    setCurrentPage(0);
  }, [debouncedSearchTerm]);

  // Load playlist data
  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const [data, statsResponse, latestTimeResponse] = await Promise.all([
          PlaylistService.getSongs(currentPage, pageSize, sortBy, sortDirection, debouncedSearchTerm),
          PlaylistService.getStats(),
          PlaylistService.getLatestSongTime()
        ]);
        
        setPlaylistData(data);
        setLatestSongTime(latestTimeResponse.timestamp);
      } catch (err) {
        console.error('Error loading playlist data:', err);
        setError('Failed to load playlist data. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [currentPage, pageSize, sortBy, sortDirection, debouncedSearchTerm]);

  const handleSort = (field: string) => {
    if (sortBy === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortDirection('asc');
    }
    setCurrentPage(0);
  };

  const formatDuration = (duration: string): string => {
    if (!duration) return '0:00';
    const [minutes, seconds] = duration.split(':').map(Number);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const formatLatestSongTime = (timestamp: string | null): string => {
    if (!timestamp) return 'Never';
    try {
      const date = new Date(timestamp);
      return date.toLocaleString();
    } catch (error) {
      return 'Unknown';
    }
  };

  if (loading) {
    return (
      <div className="playlist-container">
        <div className="loading">Loading playlist data...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="playlist-container">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="playlist-container">
      <div className="playlist-header">
        <h2>Music Playlist</h2>
        <div className="playlist-stats">
          {playlistData && (
            <>
              <span>{playlistData.totalElements.toLocaleString()} total songs</span>
              <span>•</span>
              <span>Page {playlistData.number + 1} of {playlistData.totalPages}</span>
              {latestSongTime && (
                <>
                  <span>•</span>
                  <span>Last played: {formatLatestSongTime(latestSongTime)}</span>
                </>
              )}
            </>
          )}
        </div>
      </div>

      <div className="playlist-controls">
        <div className="search-container">
          <input
            type="text"
            placeholder="Search songs..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        
        <div className="page-size-selector">
          <label>
            Show:
            <select value={pageSize} onChange={(e) => {
              setPageSize(Number(e.target.value));
              setCurrentPage(0);
            }}>
              <option value={25}>25</option>
              <option value={50}>50</option>
              <option value={100}>100</option>
            </select>
            per page
          </label>
        </div>
      </div>

      {playlistData && playlistData.content && playlistData.content.length > 0 ? (
        <>
          <div className="songs-table-container">
            <table className="songs-table">
              <thead>
                <tr>
                  <th 
                    onClick={() => handleSort('title')}
                    className={`sortable ${sortBy === 'title' ? 'active' : ''}`}
                  >
                    Song Title {sortBy === 'title' && (sortDirection === 'asc' ? '↑' : '↓')}
                  </th>
                  <th 
                    onClick={() => handleSort('duration')}
                    className={`sortable ${sortBy === 'duration' ? 'active' : ''}`}
                  >
                    Duration {sortBy === 'duration' && (sortDirection === 'asc' ? '↑' : '↓')}
                  </th>
                  <th 
                    onClick={() => handleSort('occurrence')}
                    className={`sortable ${sortBy === 'occurrence' ? 'active' : ''}`}
                  >
                    Plays {sortBy === 'occurrence' && (sortDirection === 'asc' ? '↑' : '↓')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {playlistData.content.map((song, index) => (
                  <tr key={song.id || index}>
                    <td className="song-title">{song.title}</td>
                    <td className="song-duration">{formatDuration(song.duration)}</td>
                    <td className="song-occurrence">{song.occurrence || 0}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button 
              onClick={() => setCurrentPage(0)}
              disabled={playlistData.first}
              className="pagination-btn"
            >
              First
            </button>
            <button 
              onClick={() => setCurrentPage(currentPage - 1)}
              disabled={playlistData.first}
              className="pagination-btn"
            >
              Previous
            </button>
            
            <span className="pagination-info">
              Page {playlistData.number + 1} of {playlistData.totalPages}
            </span>
            
            <button 
              onClick={() => setCurrentPage(currentPage + 1)}
              disabled={playlistData.last}
              className="pagination-btn"
            >
              Next
            </button>
            <button 
              onClick={() => setCurrentPage(playlistData.totalPages - 1)}
              disabled={playlistData.last}
              className="pagination-btn"
            >
              Last
            </button>
          </div>
        </>
      ) : (
        <div className="no-results">
          {debouncedSearchTerm ? 'No songs found matching your search.' : 'No songs available.'}
        </div>
      )}
    </div>
  );
}

export default PlaylistView;