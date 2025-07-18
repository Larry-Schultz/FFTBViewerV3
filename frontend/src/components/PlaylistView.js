import React, { useState, useEffect } from 'react';
import SearchBar from './SearchBar';
import SongTable from './SongTable';
import Pagination from './Pagination';
import PlaylistStats from './PlaylistStats';
import { PlaylistService } from '../services/PlaylistService';

function PlaylistView({ data, onDataChange }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(50);
  const [sortBy, setSortBy] = useState('title');
  const [sortDirection, setSortDirection] = useState('asc');
  const [loading, setLoading] = useState(false);
  const [latestSongTime, setLatestSongTime] = useState(null);

  useEffect(() => {
    loadData();
    loadLatestSongTime();
  }, [searchTerm, currentPage, pageSize, sortBy, sortDirection]);

  const loadData = async () => {
    try {
      setLoading(true);
      const result = await PlaylistService.getSongs(
        currentPage, 
        pageSize, 
        sortBy, 
        sortDirection, 
        searchTerm
      );
      onDataChange(result);
    } catch (error) {
      console.error('Error loading playlist data:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadLatestSongTime = async () => {
    try {
      const timestamp = await PlaylistService.getLatestSongTime();
      setLatestSongTime(timestamp);
    } catch (error) {
      console.error('Error loading latest song time:', error);
    }
  };

  const handleSearch = (term) => {
    setSearchTerm(term);
    setCurrentPage(0); // Reset to first page
  };

  const handleSort = (field) => {
    if (sortBy === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortDirection('asc');
    }
    setCurrentPage(0);
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const handlePageSizeChange = (size) => {
    setPageSize(size);
    setCurrentPage(0);
  };

  if (!data) {
    return <div className="loading">Loading playlist...</div>;
  }

  return (
    <div className="playlist-view">
      <div className="playlist-header">
        <SearchBar onSearch={handleSearch} />
        <PlaylistStats 
          totalSongs={data.totalSongs} 
          showingSongs={data.songs?.length || 0}
          latestSongTime={latestSongTime}
        />
      </div>

      <div className="playlist-content">
        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <>
            <SongTable 
              songs={data.songs || []}
              sortBy={sortBy}
              sortDirection={sortDirection}
              onSort={handleSort}
            />
            <Pagination 
              currentPage={currentPage}
              totalPages={data.totalPages || 0}
              pageSize={pageSize}
              onPageChange={handlePageChange}
              onPageSizeChange={handlePageSizeChange}
              hasNext={data.hasNext}
              hasPrevious={data.hasPrevious}
            />
          </>
        )}
      </div>
    </div>
  );
}

export default PlaylistView;