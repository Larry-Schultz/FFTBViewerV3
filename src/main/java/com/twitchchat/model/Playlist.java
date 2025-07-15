package com.twitchchat.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlRootElement;

import java.util.List;

/**
 * Model class representing the FFT Battleground playlist XML structure
 */
@JacksonXmlRootElement(localName = "playlist")
public class Playlist {
    
    @JacksonXmlProperty(localName = "title")
    private String title;
    
    @JacksonXmlElementWrapper(useWrapping = false)
    @JacksonXmlProperty(localName = "trackList")
    private TrackList trackList;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public TrackList getTrackList() {
        return trackList;
    }

    public void setTrackList(TrackList trackList) {
        this.trackList = trackList;
    }

    public static class TrackList {
        @JacksonXmlElementWrapper(useWrapping = false)
        @JacksonXmlProperty(localName = "track")
        private List<Song> tracks;

        public List<Song> getTracks() {
            return tracks;
        }

        public void setTracks(List<Song> tracks) {
            this.tracks = tracks;
        }
    }
}