export interface ChatMessage {
  username: string;
  message: string;
  timestamp: string;
  userColor?: string;
}

export interface Song {
  id: number;
  title: string;
  duration: string;
  occurrence: number;
}

export interface PlaylistData {
  content: Song[];
  number: number;
  totalPages: number;
  totalElements: number;
  first: boolean;
  last: boolean;
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