package com.example.studytrackbackend.entity;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface LoginRepository extends JpaRepository<Login, Long> {
    Login findByEmail(String email);
    Login findByUsername(String username);
    List<Login> findByAccountTypeIgnoreCase(String accountType);
    List<Login> findByDepartmentIgnoreCase(String department);
    List<Login> findBySectionIgnoreCase(String section);
    List<Login> findByCreatedAtAfter(LocalDateTime date);
    
    @Query("SELECT l.accountType as accountType, COUNT(l) as count FROM Login l GROUP BY l.accountType")
    List<Object[]> countByAccountType();
    
    @Query("SELECT l.department as department, COUNT(l) as count FROM Login l GROUP BY l.department")
    List<Object[]> countByDepartment();
    
    @Query("SELECT l FROM Login l WHERE " +
           "(:email IS NULL OR LOWER(l.email) LIKE LOWER(CONCAT('%', :email, '%'))) AND " +
           "(:username IS NULL OR LOWER(l.username) LIKE LOWER(CONCAT('%', :username, '%'))) AND " +
           "(:accountType IS NULL OR LOWER(l.accountType) = LOWER(:accountType)) AND " +
           "(:department IS NULL OR LOWER(l.department) = LOWER(:department)) AND " +
           "(:section IS NULL OR LOWER(l.section) = LOWER(:section))")
    List<Login> findBySearchCriteria(
        @Param("email") String email,
        @Param("username") String username,
        @Param("accountType") String accountType,
        @Param("department") String department,
        @Param("section") String section
    );
} 