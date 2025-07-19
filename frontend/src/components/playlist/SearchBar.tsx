import React from 'react';

interface SearchBarProps {
  onSearch: (term: string) => void;
  searchTerm: string;
}

const SearchBar: React.FC<SearchBarProps> = ({ onSearch, searchTerm }) => {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Search is handled by onChange, no need to do anything here
  };

  const handleClear = () => {
    onSearch('');
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onSearch(e.target.value);
  };

  return (
    <div className="search-container">
      <form onSubmit={handleSubmit} className="search-form">
        <div className="search-input-group">
          <input
            type="text"
            value={searchTerm}
            onChange={handleChange}
            placeholder="Search songs..."
            className="search-input"
          />
          {searchTerm && (
            <button 
              type="button" 
              onClick={handleClear} 
              className="clear-button"
              aria-label="Clear search"
            >
              ✕
            </button>
          )}
        </div>
      </form>
    </div>
  );
};

export default SearchBar;