package com.twitchchat.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlRootElement;

/**
 * Model class representing a song from the FFT Battleground playlist
 */
@JacksonXmlRootElement(localName = "track")
public class Song {
    
    @JacksonXmlProperty(localName = "title")
    private String title;
    
    @JacksonXmlProperty(localName = "creator")
    private String creator;
    
    @JacksonXmlProperty(localName = "album")
    private String album;
    
    @JacksonXmlProperty(localName = "duration")
    private String duration;
    
    @JacksonXmlProperty(localName = "location")
    private String location;

    public Song() {}

    public Song(String title, String creator, String album, String duration) {
        this.title = title;
        this.creator = creator;
        this.album = album;
        this.duration = duration;
    }

    // Getters and Setters
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}