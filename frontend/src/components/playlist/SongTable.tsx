import React from 'react';
import { Song as SongType } from '../../types';
import Song from './Song';
const styles = require('../../styles/SongTable.module.css');

interface SongTableProps {
  songs: SongType[];
  sortBy: string;
  sortDirection: 'asc' | 'desc';
  onSort: (field: string) => void;
}

const SongTable: React.FC<SongTableProps> = ({ songs, sortBy, sortDirection, onSort }) => {
  const getSortIcon = (field: string): string => {
    if (sortBy !== field) return '↕';
    return sortDirection === 'asc' ? '↑' : '↓';
  };



  return (
    <div className={styles.songTableContainer}>
      <table className={styles.songTable}>
        <thead>
          <tr>
            <th className={`${styles.songNumberHeader} ${styles.hideOnMobile}`}>#</th>
            <th 
              className={`${styles.sortable} ${styles.songTitleHeader}`} 
              onClick={() => onSort('title')}
            >
              Song Title {getSortIcon('title')}
            </th>
            <th 
              className={`${styles.sortable} ${styles.durationHeader}`} 
              onClick={() => onSort('duration')}
            >
              Duration {getSortIcon('duration')}
            </th>
            <th 
              className={`${styles.sortable} ${styles.playsHeader} ${styles.hideOnMobile}`} 
              onClick={() => onSort('occurrence')}
            >
              Plays {getSortIcon('occurrence')}
            </th>
            <th 
              className={`${styles.sortable} ${styles.dateHeader} ${styles.hideOnTablet}`} 
              onClick={() => onSort('createdAt')}
            >
              Added Date {getSortIcon('createdAt')}
            </th>
            <th 
              className={`${styles.sortable} ${styles.lastPlayedHeader} ${styles.hideOnMobile}`} 
              onClick={() => onSort('updatedAt')}
            >
              Last Played {getSortIcon('updatedAt')}
            </th>
          </tr>
        </thead>
        <tbody>
          {songs.map((song, index) => (
            <Song key={song.id || index} song={song} index={index} />
          ))}
        </tbody>
      </table>
      
      {songs.length === 0 && (
        <div className={styles.noSongs}>
          No songs found matching your search criteria.
        </div>
      )}
    </div>
  );
};

export default SongTable;