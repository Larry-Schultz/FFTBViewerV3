import React from 'react';
import { Song as SongType, SongWithTrackPlayCount, SongPlayCountView } from '../../types';
const styles = require('../../styles/Song.module.css');

interface SongProps {
  song: SongType | SongWithTrackPlayCount | SongPlayCountView;
  index: number;
}

const Song: React.FC<SongProps> = ({ song, index }) => {
  const formatDuration = (duration: string): string => {
    if (!duration || duration === '0:00') return '0:00';
    return duration;
  };

  const formatPlayCount = (count: number): string => {
    return count > 0 ? count.toString() : 'Never';
  };

  const formatDate = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Unknown';
    try {
      // Handle database timestamps - they come as "2025-07-19T15:35:44.881708" (UTC without Z)
      // Convert to proper ISO string with Z suffix for UTC
      let isoString = dateString;
      if (!dateString.includes('Z') && !dateString.includes('+') && !dateString.includes('-', 10)) {
        isoString = dateString + 'Z';
      }
      
      const date = new Date(isoString);
      if (isNaN(date.getTime())) return 'Unknown';
      
      // Get user's actual timezone instead of relying on auto-detect
      const userTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      
      const dateOptions: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZone: userTimeZone // Use detected timezone explicitly
      };
      
      return date.toLocaleString('en-US', dateOptions);
    } catch (error) {
      return 'Unknown';
    }
  };

  const formatLastPlayed = (count: number, lastPlayed?: string | null): string => {
    if (count === 0) return 'Never';
    if (lastPlayed) {
      return formatDate(lastPlayed);
    }
    return 'Never';
  };

  // Helper functions to get play count and last played time
  const getPlayCount = (): number => {
    if ('trackPlayCount' in song) {
      return song.trackPlayCount;
    }
    if ('occurrence' in song) {
      return song.occurrence;
    }
    return 0;
  };

  const getLastPlayedTime = (): string | null | undefined => {
    if ('lastPlayedAt' in song) {
      return song.lastPlayedAt;
    }
    if ('updatedAt' in song) {
      return song.updatedAt;
    }
    return null;
  };

  const getSongId = (): number => {
    if ('songId' in song) {
      return song.songId;
    }
    return song.id;
  };

  return (
    <tr className={styles.songRow}>
      <td className={`${styles.songNumber} ${styles.hideOnMobile}`}>{index + 1}</td>
      <td className={styles.songTitle}>{song.title}</td>
      <td className={styles.songDuration}>{formatDuration(song.duration)}</td>
      <td className={`${styles.songPlays} ${styles.hideOnMobile}`}>{formatPlayCount(getPlayCount())}</td>
      <td className={`${styles.songAdded} ${styles.hideOnTablet}`}>{formatDate(song.createdAt)}</td>
      <td className={`${styles.songLastPlayed} ${styles.hideOnMobile}`}>{formatLastPlayed(getPlayCount(), getLastPlayedTime())}</td>
    </tr>
  );
};

export default Song;