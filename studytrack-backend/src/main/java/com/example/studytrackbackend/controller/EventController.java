package com.example.studytrackbackend.controller;

import com.example.studytrackbackend.entity.Event;
import com.example.studytrackbackend.entity.EventRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {
    @Autowired
    private EventRepository eventRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // Create Event
    @PostMapping
    public ResponseEntity<Event> createEvent(@RequestBody Event event) {
        try {
            Event saved = eventRepository.save(event);
            messagingTemplate.convertAndSend("/topic/events", saved);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Get Events by Date
    @GetMapping
    public ResponseEntity<List<Event>> getEventsByDate(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        List<Event> events = eventRepository.findByDate(date);
        return ResponseEntity.ok(events);
    }

    // Get Event by ID
    @GetMapping("/{id}")
    public ResponseEntity<Event> getEventById(@PathVariable Long id) {
        Optional<Event> event = eventRepository.findById(id);
        return event.map(ResponseEntity::ok)
                   .orElse(ResponseEntity.notFound().build());
    }

    // Get Events by Date Range
    @GetMapping("/range")
    public ResponseEntity<List<Event>> getEventsByDateRange(
            @RequestParam("start") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam("end") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        List<Event> events = eventRepository.findByDateBetween(start, end);
        return ResponseEntity.ok(events);
    }

    // Get Events by Type
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Event>> getEventsByType(@PathVariable String type) {
        List<Event> events = eventRepository.findByTypeIgnoreCase(type);
        return ResponseEntity.ok(events);
    }

    // Get Events by Author
    @GetMapping("/author/{author}")
    public ResponseEntity<List<Event>> getEventsByAuthor(@PathVariable String author) {
        List<Event> events = eventRepository.findByEditedByIgnoreCase(author);
        return ResponseEntity.ok(events);
    }

    // Update Event
    @PutMapping("/{id}")
    public ResponseEntity<Event> updateEvent(@PathVariable Long id, @RequestBody Event eventDetails) {
        Optional<Event> eventOptional = eventRepository.findById(id);
        
        if (eventOptional.isPresent()) {
            Event event = eventOptional.get();
            event.setDate(eventDetails.getDate());
            event.setType(eventDetails.getType());
            event.setDetails(eventDetails.getDetails());
            event.setEditedBy(eventDetails.getEditedBy());
            
            Event updated = eventRepository.save(event);
            messagingTemplate.convertAndSend("/topic/events", updated);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete Event
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long id) {
        Optional<Event> eventOptional = eventRepository.findById(id);
        
        if (eventOptional.isPresent()) {
            eventRepository.deleteById(id);
            messagingTemplate.convertAndSend("/topic/events/deleted", id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Bulk Create Events
    @PostMapping("/bulk")
    public ResponseEntity<List<Event>> createBulkEvents(@RequestBody List<Event> events) {
        try {
            List<Event> savedEvents = eventRepository.saveAll(events);
            messagingTemplate.convertAndSend("/topic/events", savedEvents);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedEvents);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Search Events
    @GetMapping("/search")
    public ResponseEntity<List<Event>> searchEvents(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String author,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        List<Event> events = eventRepository.findBySearchCriteria(type, author, startDate, endDate);
        return ResponseEntity.ok(events);
    }

    // Get Event Statistics
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getEventStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalEvents", eventRepository.count());
        stats.put("eventsByType", eventRepository.countByType());
        stats.put("recentEvents", eventRepository.findByDateAfter(LocalDate.now().minusDays(7)));
        return ResponseEntity.ok(stats);
    }
} 