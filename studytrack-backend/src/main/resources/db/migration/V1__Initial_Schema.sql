-- StudyTrack Database Migration V1 - Initial Schema
-- This script creates the initial database schema

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    id BIGSERIAL PRIMARY KEY,
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL,
    details TEXT,
    edited_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create sections table
CREATE TABLE IF NOT EXISTS sections (
    id BIGSERIAL PRIMARY KEY,
    department VARCHAR(100) NOT NULL,
    section_code VARCHAR(50) NOT NULL,
    description TEXT,
    max_students INTEGER NOT NULL DEFAULT 50,
    current_students INTEGER NOT NULL DEFAULT 0,
    cr_name VARCHAR(100),
    co_cr_name VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(department, section_code)
);

-- Create logins table
CREATE TABLE IF NOT EXISTS logins (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    section VARCHAR(50),
    department VARCHAR(100),
    account_type VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    section_id BIGINT REFERENCES sections(id)
);

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id BIGSERIAL PRIMARY KEY,
    login_id BIGINT NOT NULL REFERENCES logins(id) ON DELETE CASCADE,
    display_name VARCHAR(255),
    bio TEXT,
    avatar_url VARCHAR(255),
    UNIQUE(login_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_events_date ON events(date);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(type);
CREATE INDEX IF NOT EXISTS idx_events_edited_by ON events(edited_by);
CREATE INDEX IF NOT EXISTS idx_sections_department ON sections(department);
CREATE INDEX IF NOT EXISTS idx_sections_active ON sections(is_active);
CREATE INDEX IF NOT EXISTS idx_logins_email ON logins(email);
CREATE INDEX IF NOT EXISTS idx_logins_account_type ON logins(account_type);
CREATE INDEX IF NOT EXISTS idx_logins_department ON logins(department);
CREATE INDEX IF NOT EXISTS idx_logins_section ON logins(section);

-- Insert sample data
INSERT INTO sections (department, section_code, description, max_students) VALUES
('CSE', '66-C', 'Computer Science & Engineering Section C', 50),
('CSE', '66-D', 'Computer Science & Engineering Section D', 50),
('EEE', '54-C', 'Electrical & Electronic Engineering Section C', 50),
('EEE', '54-D', 'Electrical & Electronic Engineering Section D', 50),
('SEW', '44-C', 'Software Engineering Section C', 50),
('ENG', '5-C', 'English Section C', 50)
ON CONFLICT (department, section_code) DO NOTHING;

-- Create audit trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_sections_updated_at BEFORE UPDATE ON sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_logins_updated_at BEFORE UPDATE ON logins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 