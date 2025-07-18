import axios from 'axios';

const API_BASE = '/api/playlist';

export const PlaylistService = {
  async getSongs(page = 0, size = 50, sortBy = 'title', sortDirection = 'asc', search = '') {
    try {
      const params = { page, size, sortBy, sortDirection };
      if (search) params.search = search;
      
      const response = await axios.get(`${API_BASE}/songs`, { params });
      return response.data;
    } catch (error) {
      console.error('Error fetching songs:', error);
      throw error;
    }
  },

  async getLatestSongTime() {
    try {
      const response = await axios.get(`${API_BASE}/latest-song-time`);
      return response.data.timestamp;
    } catch (error) {
      console.error('Error fetching latest song time:', error);
      return null;
    }
  },

  async getSongStats() {
    try {
      const response = await axios.get(`${API_BASE}/stats`);
      return response.data;
    } catch (error) {
      console.error('Error fetching song stats:', error);
      throw error;
    }
  }
};