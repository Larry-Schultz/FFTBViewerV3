export interface ChatMessage {
  username: string;
  message: string;
  timestamp: string;
  userColor?: string;
}

export interface Song {
  id: number;
  title: string;
  creator?: string | null;
  album?: string | null;
  duration: string;
  location?: string | null;
  createdAt?: string;
  updatedAt?: string | null;
  occurrence: number;
  lastPlayed?: string;
}

export interface PlaylistData {
  totalSongs?: number;
  songs?: Song[];
  showingSongs?: number;
  totalPages: number;
  hasPrevious?: boolean;
  hasNext?: boolean;
  currentPage?: number;
  // Legacy Spring Boot pagination format
  content?: Song[];
  number?: number;
  totalElements?: number;
  first?: boolean;
  last?: boolean;
}

export interface PlaylistStats {
  totalSongs: number;
  totalDuration: string;
  mostPlayedSong: string;
}

export interface LatestSongResponse {
  timestamp: string;
}

export type ViewType = 'chat' | 'playlist';