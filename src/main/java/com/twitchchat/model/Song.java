package com.twitchchat.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlRootElement;
import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity class representing a song from the FFT Battleground playlist
 */
@Entity
@Table(name = "songs", indexes = {
    @Index(name = "idx_title", columnList = "title"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@JacksonXmlRootElement(localName = "track")
public class Song {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "title", nullable = false, length = 1000)
    @JacksonXmlProperty(localName = "title")
    private String title;
    
    @Column(name = "creator", length = 500)
    @JacksonXmlProperty(localName = "creator")
    private String creator;
    
    @Column(name = "album", length = 500)
    @JacksonXmlProperty(localName = "album")
    private String album;
    
    @Column(name = "duration", length = 20)
    @JacksonXmlProperty(localName = "duration")
    private String duration;
    
    @Column(name = "location", length = 1000)
    @JacksonXmlProperty(localName = "location")
    private String location;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public Song() {
        this.createdAt = LocalDateTime.now();
    }

    public Song(String title, String creator, String album, String duration) {
        this.title = title;
        this.creator = creator;
        this.album = album;
        this.duration = duration;
        this.createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
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

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Song)) return false;
        Song song = (Song) o;
        return title != null && title.equals(song.title);
    }

    @Override
    public int hashCode() {
        return title != null ? title.hashCode() : 0;
    }
}