package com.example.studytrackbackend.controller;

import com.example.studytrackbackend.entity.Section;
import com.example.studytrackbackend.entity.SectionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/sections")
@CrossOrigin(origins = "*")
public class SectionController {
    @Autowired
    private SectionRepository sectionRepository;

    // Create Section
    @PostMapping
    public ResponseEntity<Section> createSection(@RequestBody Section section) {
        try {
            // Check if section already exists
            Optional<Section> existing = sectionRepository.findByDepartmentAndSectionCodeIgnoreCase(
                section.getDepartment(), section.getSectionCode());
            
            if (existing.isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT).build();
            }
            
            Section saved = sectionRepository.save(section);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Get All Sections
    @GetMapping
    public ResponseEntity<List<Section>> getAllSections() {
        List<Section> sections = sectionRepository.findByIsActiveTrue();
        return ResponseEntity.ok(sections);
    }

    // Get Section by ID
    @GetMapping("/{id}")
    public ResponseEntity<Section> getSectionById(@PathVariable Long id) {
        Optional<Section> section = sectionRepository.findById(id);
        return section.map(ResponseEntity::ok)
                     .orElse(ResponseEntity.notFound().build());
    }

    // Get Sections by Department
    @GetMapping("/department/{department}")
    public ResponseEntity<List<Section>> getSectionsByDepartment(@PathVariable String department) {
        List<Section> sections = sectionRepository.findByDepartmentIgnoreCase(department);
        return ResponseEntity.ok(sections);
    }

    // Get Available Sections (with available seats)
    @GetMapping("/available")
    public ResponseEntity<List<Section>> getAvailableSections() {
        List<Section> sections = sectionRepository.findAvailableSections();
        return ResponseEntity.ok(sections);
    }

    // Update Section
    @PutMapping("/{id}")
    public ResponseEntity<Section> updateSection(@PathVariable Long id, @RequestBody Section sectionDetails) {
        Optional<Section> sectionOptional = sectionRepository.findById(id);
        
        if (sectionOptional.isPresent()) {
            Section section = sectionOptional.get();
            section.setDepartment(sectionDetails.getDepartment());
            section.setSectionCode(sectionDetails.getSectionCode());
            section.setDescription(sectionDetails.getDescription());
            section.setMaxStudents(sectionDetails.getMaxStudents());
            section.setCrName(sectionDetails.getCrName());
            section.setCoCrName(sectionDetails.getCoCrName());
            section.setIsActive(sectionDetails.getIsActive());
            
            Section updated = sectionRepository.save(section);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete Section (Soft Delete)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSection(@PathVariable Long id) {
        Optional<Section> sectionOptional = sectionRepository.findById(id);
        
        if (sectionOptional.isPresent()) {
            Section section = sectionOptional.get();
            section.setIsActive(false);
            sectionRepository.save(section);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Assign CR/Co-CR
    @PutMapping("/{id}/assign-cr")
    public ResponseEntity<Section> assignCR(@PathVariable Long id, @RequestBody Map<String, String> request) {
        Optional<Section> sectionOptional = sectionRepository.findById(id);
        
        if (sectionOptional.isPresent()) {
            Section section = sectionOptional.get();
            section.setCrName(request.get("crName"));
            section.setCoCrName(request.get("coCrName"));
            
            Section updated = sectionRepository.save(section);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get Section Statistics
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getSectionStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalSections", sectionRepository.count());
        stats.put("activeSections", sectionRepository.findByIsActiveTrue().size());
        stats.put("availableSections", sectionRepository.findAvailableSections().size());
        stats.put("sectionsByDepartment", sectionRepository.countSectionsByDepartment());
        return ResponseEntity.ok(stats);
    }

    // Bulk Create Sections
    @PostMapping("/bulk")
    public ResponseEntity<List<Section>> createBulkSections(@RequestBody List<Section> sections) {
        try {
            List<Section> savedSections = sectionRepository.saveAll(sections);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedSections);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Search Sections
    @GetMapping("/search")
    public ResponseEntity<List<Section>> searchSections(
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String sectionCode,
            @RequestParam(required = false) Boolean hasAvailableSeats) {
        
        List<Section> sections;
        if (hasAvailableSeats != null && hasAvailableSeats) {
            sections = sectionRepository.findAvailableSections();
        } else if (department != null && sectionCode != null) {
            Optional<Section> section = sectionRepository.findByDepartmentAndSectionCodeIgnoreCase(department, sectionCode);
            sections = section.map(List::of).orElse(List.of());
        } else if (department != null) {
            sections = sectionRepository.findByDepartmentIgnoreCase(department);
        } else {
            sections = sectionRepository.findByIsActiveTrue();
        }
        
        return ResponseEntity.ok(sections);
    }
} 