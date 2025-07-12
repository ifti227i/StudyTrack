package com.example.studytrackbackend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
@CrossOrigin(origins = "*")
public class HealthController {
    
    @Autowired
    private DataSource dataSource;

    @GetMapping
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", LocalDateTime.now());
        health.put("service", "StudyTrack Backend");
        health.put("version", "1.0.0");
        
        // Check database connectivity
        try (Connection connection = dataSource.getConnection()) {
            health.put("database", "UP");
            health.put("databaseUrl", connection.getMetaData().getURL());
        } catch (Exception e) {
            health.put("database", "DOWN");
            health.put("databaseError", e.getMessage());
        }
        
        return ResponseEntity.ok(health);
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readinessCheck() {
        Map<String, Object> readiness = new HashMap<>();
        readiness.put("status", "READY");
        readiness.put("timestamp", LocalDateTime.now());
        
        // Check if all required services are ready
        boolean isReady = true;
        
        // Database check
        try (Connection connection = dataSource.getConnection()) {
            readiness.put("database", "READY");
        } catch (Exception e) {
            readiness.put("database", "NOT_READY");
            readiness.put("databaseError", e.getMessage());
            isReady = false;
        }
        
        readiness.put("overall", isReady ? "READY" : "NOT_READY");
        
        return ResponseEntity.ok(readiness);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> applicationInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "StudyTrack Backend");
        info.put("version", "1.0.0");
        info.put("description", "Academic Calendar and Section Management System");
        info.put("javaVersion", System.getProperty("java.version"));
        info.put("springVersion", "3.5.3");
        info.put("database", "PostgreSQL");
        info.put("authentication", "OAuth2 with Google");
        info.put("features", new String[]{
            "Event Management",
            "Section Management", 
            "User Management",
            "Real-time Updates",
            "OAuth2 Authentication"
        });
        
        return ResponseEntity.ok(info);
    }
} 