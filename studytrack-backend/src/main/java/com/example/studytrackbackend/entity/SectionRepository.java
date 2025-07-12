package com.example.studytrackbackend.entity;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface SectionRepository extends JpaRepository<Section, Long> {
    List<Section> findByDepartmentIgnoreCase(String department);
    List<Section> findByIsActiveTrue();
    Optional<Section> findByDepartmentAndSectionCodeIgnoreCase(String department, String sectionCode);
    List<Section> findByCurrentStudentsLessThanMaxStudents();
    
    @Query("SELECT s FROM Section s WHERE s.department = :department AND s.sectionCode = :sectionCode AND s.isActive = true")
    Optional<Section> findActiveSection(@Param("department") String department, @Param("sectionCode") String sectionCode);
    
    @Query("SELECT s FROM Section s WHERE s.currentStudents < s.maxStudents AND s.isActive = true")
    List<Section> findAvailableSections();
    
    @Query("SELECT s.department, COUNT(s) FROM Section s WHERE s.isActive = true GROUP BY s.department")
    List<Object[]> countSectionsByDepartment();
} 