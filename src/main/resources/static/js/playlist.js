// Playlist functionality
class PlaylistManager {
    constructor() {
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupPaginationHandlers();
    }

    setupEventListeners() {
        // Sortable column headers
        const sortableHeaders = document.querySelectorAll('.sortable');
        sortableHeaders.forEach(header => {
            header.addEventListener('click', (e) => {
                e.preventDefault();
                this.handleColumnSort(header);
            });
        });
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

    handleColumnSort(header) {
        const sortBy = header.dataset.sort;
        const currentUrl = new URL(window.location);
        
        // Get current sort parameters
        const currentSortBy = currentUrl.searchParams.get('sortBy') || 'title';
        const currentSortDirection = currentUrl.searchParams.get('sortDirection') || 'asc';
        
        // Determine new sort direction
        let newSortDirection = 'asc';
        if (currentSortBy === sortBy) {
            // If clicking the same column, toggle direction
            newSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
        }
        
        // Update URL parameters
        currentUrl.searchParams.set('sortBy', sortBy);
        currentUrl.searchParams.set('sortDirection', newSortDirection);
        currentUrl.searchParams.set('page', '0'); // Reset to first page when sorting
        
        // Navigate to new URL
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