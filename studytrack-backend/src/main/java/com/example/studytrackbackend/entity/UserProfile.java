package com.example.studytrackbackend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "user_profiles")
@Data
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "login_id", nullable = false)
    private Login login;

    @Column(length = 255)
    private String displayName;

    @Column(length = 500)
    private String bio;

    @Column(length = 255)
    private String avatarUrl;
} 