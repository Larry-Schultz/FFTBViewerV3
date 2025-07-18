import React from 'react';

function Pagination({ 
  currentPage, 
  totalPages, 
  pageSize, 
  onPageChange, 
  onPageSizeChange, 
  hasNext, 
  hasPrevious 
}) {
  const pageSizeOptions = [10, 25, 50, 100, 250, 500];

  return (
    <div className="pagination">
      <div className="pagination-info">
        <span>Page {currentPage + 1} of {totalPages}</span>
      </div>
      
      <div className="pagination-controls">
        <button 
          onClick={() => onPageChange(currentPage - 1)}
          disabled={!hasPrevious}
          className="btn btn-secondary"
        >
          Previous
        </button>
        
        <button 
          onClick={() => onPageChange(currentPage + 1)}
          disabled={!hasNext}
          className="btn btn-secondary"
        >
          Next
        </button>
      </div>

      <div className="page-size-selector">
        <label htmlFor="page-size">Page Size:</label>
        <select 
          id="page-size"
          value={pageSize} 
          onChange={(e) => onPageSizeChange(parseInt(e.target.value))}
        >
          {pageSizeOptions.map(size => (
            <option key={size} value={size}>{size}</option>
          ))}
        </select>
      </div>
    </div>
  );
}

export default Pagination;