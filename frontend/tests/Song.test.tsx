import React from 'react';
import { render, screen } from '@testing-library/react';
import Song from '../src/components/playlist/Song';
import { SongPlayCountView } from '../src/types';

// Mock CSS modules
jest.mock('../src/styles/Song.module.css', () => ({
  songRow: 'songRow',
  title: 'title',
  duration: 'duration',
  trackPlays: 'trackPlays',
  lastPlayed: 'lastPlayed'
}));

describe('Song Component', () => {
  const mockSong: SongPlayCountView = {
    songId: 1,
    title: 'Test Song',
    duration: '3:45',
    trackPlayCount: 5,
    lastPlayedAt: '2025-07-19T15:42:46.514608',
    album: null,
    creator: null,
    location: null,
    occurrence: 5,
    createdAt: '2025-07-16T10:00:00',
    updatedAt: '2025-07-19T15:42:46.514608'
  };

  test('renders song information correctly', () => {
    render(<Song song={mockSong} index={0} />);
    
    expect(screen.getByText('Test Song')).toBeInTheDocument();
    expect(screen.getByText('3:45')).toBeInTheDocument();
    expect(screen.getByText('5')).toBeInTheDocument();
  });

  test('formats UTC timestamp to Central Time correctly', () => {
    render(<Song song={mockSong} index={0} />);
    
    // The UTC timestamp 2025-07-19T15:42:46 should convert to Central Time (10:42:46 AM)
    const timestampElement = screen.getByText(/10:42:46 AM/i);
    expect(timestampElement).toBeInTheDocument();
  });

  test('handles null lastPlayedAt correctly', () => {
    const songWithoutPlay = { ...mockSong, trackPlayCount: 0, lastPlayedAt: null };
    render(<Song song={songWithoutPlay} index={0} />);
    
    expect(screen.getByText('Never')).toBeInTheDocument();
  });
});

// Standalone test for formatDate function logic
describe('formatDate timezone conversion', () => {
  const formatDate = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Unknown';
    try {
      let isoString = dateString;
      if (!dateString.includes('Z') && !dateString.includes('+') && !dateString.includes('-', 10)) {
        isoString = dateString + 'Z';
      }
      
      const date = new Date(isoString);
      if (isNaN(date.getTime())) return 'Unknown';
      
      const dateOptions: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZone: 'America/Chicago'
      };
      
      return date.toLocaleString('en-US', dateOptions);
    } catch (error) {
      return 'Unknown';
    }
  };

  test('converts UTC timestamp to Central Time correctly', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    const result = formatDate(utcTimestamp);
    
    // UTC 15:42:46 should be Central 10:42:46 AM
    expect(result).toContain('10:42:46 AM');
    expect(result).toContain('Jul 19, 2025');
  });

  test('handles timestamp without Z suffix', () => {
    const timestampWithoutZ = '2025-07-19T15:35:44.881708';
    const result = formatDate(timestampWithoutZ);
    
    // Should automatically append Z and convert to Central
    expect(result).toContain('10:35:44 AM');
  });

  test('handles null and undefined values', () => {
    expect(formatDate(null)).toBe('Unknown');
    expect(formatDate(undefined)).toBe('Unknown');
    expect(formatDate('')).toBe('Unknown');
  });
});