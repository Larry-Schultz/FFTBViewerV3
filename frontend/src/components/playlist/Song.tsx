import React from 'react';
import { Song as SongType } from '../../types';
const styles = require('../../styles/Song.module.css');

interface SongProps {
  song: SongType;
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
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return 'Unknown';
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
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

  return (
    <tr className={styles.songRow}>
      <td className={`${styles.songNumber} ${styles.hideOnMobile}`}>{index + 1}</td>
      <td className={styles.songTitle}>{song.title}</td>
      <td className={styles.songDuration}>{formatDuration(song.duration)}</td>
      <td className={`${styles.songPlays} ${styles.hideOnMobile}`}>{formatPlayCount(song.occurrence)}</td>
      <td className={`${styles.songAdded} ${styles.hideOnTablet}`}>{formatDate(song.createdAt)}</td>
      <td className={`${styles.songLastPlayed} ${styles.hideOnMobile}`}>{formatLastPlayed(song.occurrence, song.updatedAt)}</td>
    </tr>
  );
};

export default Song;