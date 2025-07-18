export class PlaylistService {
  static async getSongs(page = 0, size = 50, sortBy = 'title', sortDirection = 'asc', search = '') {
    const params = new URLSearchParams({
      page: page.toString(),
      size: size.toString(),
      sortBy,
      sortDirection
    });
    
    if (search.trim()) {
      params.append('search', search.trim());
    }

    const response = await fetch(`/api/songs?${params}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  }

  static async getStats() {
    const response = await fetch('/api/stats');
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  }

  static async getLatestSongTime() {
    const response = await fetch('/api/latest-song-time');
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  }
}