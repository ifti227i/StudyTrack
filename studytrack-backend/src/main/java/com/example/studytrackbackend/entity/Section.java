package com.example.studytrackbackend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "sections")
@Data
public class Section {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String department;

    @Column(nullable = false, length = 50)
    private String sectionCode;

    @Column(length = 255)
    private String description;

    @Column(nullable = false)
    private Integer maxStudents = 50;

    @Column(nullable = false)
    private Integer currentStudents = 0;

    @Column(length = 100)
    private String crName; // Class Representative

    @Column(length = 100)
    private String coCrName; // Co-Class Representative

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column(nullable = false)
    private Boolean isActive = true;

    @OneToMany(mappedBy = "sectionEntity", fetch = FetchType.LAZY)
    private List<Login> students;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper methods
    public boolean hasAvailableSeats() {
        return currentStudents < maxStudents;
    }

    public void addStudent() {
        if (hasAvailableSeats()) {
            currentStudents++;
        }
    }

    public void removeStudent() {
        if (currentStudents > 0) {
            currentStudents--;
        }
    }
} 