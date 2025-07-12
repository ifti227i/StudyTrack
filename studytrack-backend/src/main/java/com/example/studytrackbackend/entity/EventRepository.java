package com.example.studytrackbackend.entity;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByDate(LocalDate date);
    List<Event> findByDateBetween(LocalDate start, LocalDate end);
    List<Event> findByTypeIgnoreCase(String type);
    List<Event> findByEditedByIgnoreCase(String editedBy);
    List<Event> findByDateAfter(LocalDate date);
    
    @Query("SELECT e FROM Event e WHERE " +
           "(:type IS NULL OR LOWER(e.type) = LOWER(:type)) AND " +
           "(:author IS NULL OR LOWER(e.editedBy) = LOWER(:author)) AND " +
           "(:startDate IS NULL OR e.date >= :startDate) AND " +
           "(:endDate IS NULL OR e.date <= :endDate)")
    List<Event> findBySearchCriteria(
        @Param("type") String type,
        @Param("author") String author,
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate
    );
    
    @Query("SELECT e.type as type, COUNT(e) as count FROM Event e GROUP BY e.type")
    List<Object[]> countByType();
} 