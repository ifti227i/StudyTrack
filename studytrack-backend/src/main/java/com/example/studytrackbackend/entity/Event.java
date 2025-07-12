package com.example.studytrackbackend.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "events")
public class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false, length = 50)
    private String type;

    @Column(length = 2000)
    private String details;

    @Column(nullable = false, length = 255)
    private String editedBy;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Default constructor
    public Event() {}

    // Constructor with fields
    public Event(LocalDate date, String type, String details, String editedBy) {
        this.date = date;
        this.type = type;
        this.details = details;
        this.editedBy = editedBy;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getEditedBy() { return editedBy; }
    public void setEditedBy(String editedBy) { this.editedBy = editedBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Event{" +
                "id=" + id +
                ", date=" + date +
                ", type='" + type + '\'' +
                ", details='" + details + '\'' +
                ", editedBy='" + editedBy + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
} 