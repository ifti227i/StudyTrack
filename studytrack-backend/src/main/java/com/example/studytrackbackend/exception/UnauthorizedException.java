package com.example.studytrackbackend.exception;

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
    
    public UnauthorizedException() {
        super("Access denied. Authentication required.");
    }
} 