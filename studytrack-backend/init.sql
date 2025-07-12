-- StudyTrack Database Initialization Script for PostgreSQL
-- This script creates the database and initial tables

-- Create database (if not exists)
-- Note: This should be run by a database admin
-- CREATE DATABASE studytrack_db;

-- Connect to the database
-- \c studytrack_db;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables (these will be created by Hibernate, but here for reference)
-- The actual table creation is handled by JPA/Hibernate with ddl-auto=update

-- Sample data insertion (optional)
-- INSERT INTO logins (email, password, username, account_type) 
-- VALUES ('admin@example.com', 'hashed_password', 'admin', 'Personal');

-- INSERT INTO events (date, type, details, edited_by, created_at)
-- VALUES ('2025-01-15', 'general', 'Sample event', 'admin', NOW());

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO studytrack_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO studytrack_user; 