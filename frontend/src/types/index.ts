export interface ChatMessage {
  username: string;
  message: string;
  timestamp: string;
  channel?: string;
  userColor?: string;
}

export interface Song {
  id: number;
  title: string;
  creator?: string;
  album?: string;
  duration: string;
  location?: string;
  createdAt: string;
  updatedAt?: string;
  occurrence: number;
}

export interface PlaylistData {
  totalSongs: number;
  songs: Song[];
  showingSongs: number;
  totalPages: number;
  hasPrevious: boolean;
  hasNext: boolean;
  currentPage: number;
}

export interface PlaylistStats {
  totalSongs: number;
  latestSongTime?: string;
}

export type ViewType = 'chat' | 'playlist';
export type SortDirection = 'asc' | 'desc';