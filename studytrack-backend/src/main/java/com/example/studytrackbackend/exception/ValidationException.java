package com.example.studytrackbackend.exception;

public class ValidationException extends RuntimeException {
    public ValidationException(String message) {
        super(message);
    }
    
    public ValidationException(String fieldName, String error) {
        super(String.format("Validation failed for field '%s': %s", fieldName, error));
    }
} 