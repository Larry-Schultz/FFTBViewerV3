import React, { useState } from 'react';

function SearchBar({ onSearch }) {
  const [searchTerm, setSearchTerm] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSearch(searchTerm);
  };

  const handleClear = () => {
    setSearchTerm('');
    onSearch('');
  };

  return (
    <div className="search-bar">
      <form onSubmit={handleSubmit} className="search-form">
        <div className="search-input-group">
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search songs..."
            className="search-input"
          />
          <button type="submit" className="search-button">
            🔍
          </button>
          {searchTerm && (
            <button type="button" onClick={handleClear} className="clear-button">
              ✕
            </button>
          )}
        </div>
      </form>
    </div>
  );
}

export default SearchBar;