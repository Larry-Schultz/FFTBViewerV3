// Playlist functionality
class PlaylistManager {
    constructor() {
        this.originalRows = [];
        this.init();
    }

    init() {
        this.cacheOriginalRows();
        this.setupEventListeners();
        this.setupPaginationHandlers();
        this.updateShowingCount();
    }

    cacheOriginalRows() {
        const tbody = document.querySelector('#playlist-table tbody');
        this.originalRows = Array.from(tbody.querySelectorAll('.song-row'));
    }

    setupEventListeners() {
        // Search functionality
        const searchInput = document.getElementById('song-search');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.filterSongs(e.target.value);
            });
        }

        // Filter buttons
        const filterButtons = document.querySelectorAll('.filter-btn');
        filterButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.handleFilterClick(e.target);
            });
        });
    }

    filterSongs(searchTerm) {
        const tbody = document.querySelector('#playlist-table tbody');
        const rows = tbody.querySelectorAll('.song-row');
        const term = searchTerm.toLowerCase().trim();
        let visibleCount = 0;

        rows.forEach(row => {
            const title = row.querySelector('.song-title').textContent.toLowerCase();
            
            const matches = !term || title.includes(term);
            
            if (matches) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        this.updateShowingCount(visibleCount);
    }

    handleFilterClick(button) {
        // Update active button
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        button.classList.add('active');

        const filterType = button.dataset.filter;
        
        if (filterType === 'all') {
            this.resetSorting();
        } else {
            this.sortTable(filterType);
        }
    }

    sortTable(sortBy) {
        const tbody = document.querySelector('#playlist-table tbody');
        const rows = Array.from(tbody.querySelectorAll('.song-row'));
        
        rows.sort((a, b) => {
            let aValue, bValue;
            
            switch(sortBy) {
                case 'title':
                    aValue = a.querySelector('.song-title').textContent.trim();
                    bValue = b.querySelector('.song-title').textContent.trim();
                    break;
                case 'duration':
                    aValue = a.querySelector('.song-duration').textContent.trim();
                    bValue = b.querySelector('.song-duration').textContent.trim();
                    break;
                default:
                    return 0;
            }
            
            return aValue.localeCompare(bValue);
        });

        // Clear and re-append sorted rows
        tbody.innerHTML = '';
        rows.forEach((row, index) => {
            // Update track number
            row.querySelector('.track-number').textContent = index + 1;
            tbody.appendChild(row);
        });

        // Re-apply current search filter
        const searchInput = document.getElementById('song-search');
        if (searchInput && searchInput.value) {
            this.filterSongs(searchInput.value);
        }
    }

    resetSorting() {
        const tbody = document.querySelector('#playlist-table tbody');
        
        // Clear current content
        tbody.innerHTML = '';
        
        // Restore original order
        this.originalRows.forEach((row, index) => {
            // Reset track number to original
            row.querySelector('.track-number').textContent = index + 1;
            tbody.appendChild(row);
        });

        // Re-apply current search filter
        const searchInput = document.getElementById('song-search');
        if (searchInput && searchInput.value) {
            this.filterSongs(searchInput.value);
        } else {
            this.updateShowingCount();
        }
    }

    updateShowingCount(count) {
        const showingElement = document.getElementById('showing-count');
        if (showingElement) {
            const finalCount = count !== undefined ? count : this.originalRows.length;
            showingElement.textContent = finalCount;
        }
    }

    setupPaginationHandlers() {
        // Handle page size changes
        const pageSizeSelect = document.getElementById('page-size');
        if (pageSizeSelect) {
            pageSizeSelect.addEventListener('change', (e) => {
                this.changePageSize(e.target.value);
            });
        }
    }

    changePageSize(newSize) {
        const currentUrl = new URL(window.location);
        currentUrl.searchParams.set('size', newSize);
        currentUrl.searchParams.set('page', '0'); // Reset to first page
        window.location.href = currentUrl.toString();
    }
}

// Initialize playlist manager when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const playlistManager = new PlaylistManager();
    console.log('Playlist manager initialized successfully');
});

// Add some visual feedback for table interactions
document.addEventListener('DOMContentLoaded', () => {
    const table = document.getElementById('playlist-table');
    if (table) {
        table.addEventListener('click', (e) => {
            if (e.target.closest('.song-row')) {
                const row = e.target.closest('.song-row');
                const title = row.querySelector('.song-title').textContent;
                const artist = row.querySelector('.song-artist').textContent;
                
                // Add a subtle flash effect
                row.style.background = 'rgba(145, 70, 255, 0.3)';
                setTimeout(() => {
                    row.style.background = '';
                }, 200);
                
                console.log(`Selected: ${title} by ${artist}`);
            }
        });
    }
});