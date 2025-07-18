import React, { useState, useEffect } from 'react';
import { PlaylistService } from '../../services/PlaylistService';
import { PlaylistData } from '../../types';
import SearchBar from './SearchBar';
import SongTable from './SongTable';
import Pagination from './Pagination';
import PlaylistStats from './PlaylistStats';

const PlaylistView: React.FC = () => {
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

  const handleSearch = (term: string) => {
    setSearchTerm(term);
  };

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const handlePageSizeChange = (size: number) => {
    setPageSize(size);
    setCurrentPage(0);
  };

  if (loading) {
    return (
      <div className="playlist-container">
        <div className="loading-message">Loading playlist...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="playlist-container">
        <div className="error-message">{error}</div>
      </div>
    );
  }

  if (!playlistData) {
    return (
      <div className="playlist-container">
        <div className="error-message">No playlist data available</div>
      </div>
    );
  }

  return (
    <div className="playlist-container">
      <SearchBar onSearch={handleSearch} searchTerm={searchTerm} />
      
      <SongTable 
        songs={playlistData?.content || playlistData?.songs || []}
        sortBy={sortBy}
        sortDirection={sortDirection}
        onSort={handleSort}
      />
      
      <div className="playlist-footer">
        {playlistData && (
          <PlaylistStats 
            totalSongs={playlistData.totalElements || playlistData.totalSongs || 0}
            showingSongs={playlistData.content?.length || playlistData.songs?.length || 0}
            latestSongTime={latestSongTime}
          />
        )}
        
        <Pagination
          currentPage={currentPage}
          totalPages={playlistData?.totalPages || 0}
          pageSize={pageSize}
          onPageChange={handlePageChange}
          onPageSizeChange={handlePageSizeChange}
          hasNext={playlistData?.hasNext || !(playlistData?.last ?? true)}
          hasPrevious={playlistData?.hasPrevious || !(playlistData?.first ?? true)}
        />
      </div>
    </div>
  );
};

export default PlaylistView;