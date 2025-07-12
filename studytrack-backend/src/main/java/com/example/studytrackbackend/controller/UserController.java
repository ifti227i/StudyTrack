package com.example.studytrackbackend.controller;

import com.example.studytrackbackend.entity.UserProfile;
import com.example.studytrackbackend.entity.UserProfileRepository;
import com.example.studytrackbackend.entity.Login;
import com.example.studytrackbackend.entity.LoginRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    private UserProfileRepository userProfileRepository;
    @Autowired
    private LoginRepository loginRepository;

    @GetMapping("/")
    public String home() {
        return "Welcome! <a href=\"/oauth2/authorization/google\">Login with Google</a>";
    }

    @GetMapping("/user")
    public ResponseEntity<OidcUser> getUser(@AuthenticationPrincipal OidcUser principal) {
        if (principal != null) {
            return ResponseEntity.ok(principal);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/auth/google")
    public ResponseEntity<Map<String, Object>> googleAuth(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        String email = request.get("email");
        String name = request.get("name");
        String section = request.get("section");
        String department = request.get("department");
        String accountType = request.get("accountType");
        String accessToken = request.get("accessToken");

        if (email != null && !email.isEmpty()) {
            Login user = loginRepository.findByEmail(email);
            if (user == null) {
                user = new Login();
                user.setEmail(email);
                user.setUsername(email.split("@")[0] + System.currentTimeMillis());
                user.setPassword("GOOGLE_USER");
                user.setSection(section);
                user.setDepartment(department);
                user.setAccountType(accountType);
                loginRepository.save(user);
                
                UserProfile profile = new UserProfile();
                profile.setLogin(user);
                profile.setDisplayName(name);
                userProfileRepository.save(profile);
            } else {
                // Update existing user information
                user.setSection(section);
                user.setDepartment(department);
                user.setAccountType(accountType);
                loginRepository.save(user);
                
                // Update profile if exists
                Optional<UserProfile> profileOpt = userProfileRepository.findByLogin(user);
                if (profileOpt.isPresent()) {
                    UserProfile profile = profileOpt.get();
                    profile.setDisplayName(name);
                    userProfileRepository.save(profile);
                }
            }
            response.put("success", true);
            response.put("email", email);
            response.put("message", "Google authentication successful");
            response.put("sessionToken", "demo-session-token-" + System.currentTimeMillis());
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Invalid email provided");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/auth/success")
    public ResponseEntity<Map<String, Object>> authSuccess(@AuthenticationPrincipal OidcUser principal) {
        Map<String, Object> response = new HashMap<>();
        
        if (principal != null) {
            response.put("success", true);
            response.put("email", principal.getEmail());
            response.put("name", principal.getName());
            response.put("picture", principal.getPicture());
            response.put("message", "Authentication successful");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "User not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @GetMapping("/auth/status")
    public ResponseEntity<Map<String, Object>> authStatus(@AuthenticationPrincipal OidcUser principal) {
        Map<String, Object> response = new HashMap<>();
        response.put("authenticated", principal != null);
        
        if (principal != null) {
            response.put("email", principal.getEmail());
            response.put("name", principal.getName());
        }
        
        return ResponseEntity.ok(response);
    }

    // Create User Profile
    @PostMapping("/profiles")
    public ResponseEntity<UserProfile> createUserProfile(@RequestBody UserProfile userProfile) {
        try {
            UserProfile saved = userProfileRepository.save(userProfile);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Get All User Profiles
    @GetMapping("/profiles")
    public ResponseEntity<List<UserProfile>> getAllUserProfiles() {
        List<UserProfile> profiles = userProfileRepository.findAll();
        return ResponseEntity.ok(profiles);
    }

    // Get User Profile by ID
    @GetMapping("/profiles/{id}")
    public ResponseEntity<UserProfile> getUserProfileById(@PathVariable Long id) {
        Optional<UserProfile> profile = userProfileRepository.findById(id);
        return profile.map(ResponseEntity::ok)
                     .orElse(ResponseEntity.notFound().build());
    }

    // Get User Profile by Email
    @GetMapping("/profiles/email/{email}")
    public ResponseEntity<UserProfile> getUserProfileByEmail(@PathVariable String email) {
        Login user = loginRepository.findByEmail(email);
        if (user != null) {
            Optional<UserProfile> profile = userProfileRepository.findByLogin(user);
            return profile.map(ResponseEntity::ok)
                         .orElse(ResponseEntity.notFound().build());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Update User Profile
    @PutMapping("/profiles/{id}")
    public ResponseEntity<UserProfile> updateUserProfile(@PathVariable Long id, @RequestBody UserProfile profileDetails) {
        Optional<UserProfile> profileOptional = userProfileRepository.findById(id);
        
        if (profileOptional.isPresent()) {
            UserProfile profile = profileOptional.get();
            profile.setDisplayName(profileDetails.getDisplayName());
            profile.setBio(profileDetails.getBio());
            profile.setAvatarUrl(profileDetails.getAvatarUrl());
            
            UserProfile updated = userProfileRepository.save(profile);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete User Profile
    @DeleteMapping("/profiles/{id}")
    public ResponseEntity<Void> deleteUserProfile(@PathVariable Long id) {
        Optional<UserProfile> profileOptional = userProfileRepository.findById(id);
        
        if (profileOptional.isPresent()) {
            userProfileRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get Users by Account Type
    @GetMapping("/type/{accountType}")
    public ResponseEntity<List<Login>> getUsersByAccountType(@PathVariable String accountType) {
        List<Login> users = loginRepository.findByAccountTypeIgnoreCase(accountType);
        return ResponseEntity.ok(users);
    }

    // Get Users by Department
    @GetMapping("/department/{department}")
    public ResponseEntity<List<Login>> getUsersByDepartment(@PathVariable String department) {
        List<Login> users = loginRepository.findByDepartmentIgnoreCase(department);
        return ResponseEntity.ok(users);
    }

    // Get Users by Section
    @GetMapping("/section/{section}")
    public ResponseEntity<List<Login>> getUsersBySection(@PathVariable String section) {
        List<Login> users = loginRepository.findBySectionIgnoreCase(section);
        return ResponseEntity.ok(users);
    }

    // Update User Account Information
    @PutMapping("/{id}")
    public ResponseEntity<Login> updateUser(@PathVariable Long id, @RequestBody Login userDetails) {
        Optional<Login> userOptional = loginRepository.findById(id);
        
        if (userOptional.isPresent()) {
            Login user = userOptional.get();
            user.setUsername(userDetails.getUsername());
            user.setSection(userDetails.getSection());
            user.setDepartment(userDetails.getDepartment());
            user.setAccountType(userDetails.getAccountType());
            
            Login updated = loginRepository.save(user);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get User Statistics
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getUserStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", loginRepository.count());
        stats.put("usersByAccountType", loginRepository.countByAccountType());
        stats.put("usersByDepartment", loginRepository.countByDepartment());
        stats.put("recentRegistrations", loginRepository.findByCreatedAtAfter(java.time.LocalDateTime.now().minusDays(30)));
        return ResponseEntity.ok(stats);
    }

    // Search Users
    @GetMapping("/search")
    public ResponseEntity<List<Login>> searchUsers(
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String accountType,
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String section) {
        
        List<Login> users = loginRepository.findBySearchCriteria(email, username, accountType, department, section);
        return ResponseEntity.ok(users);
    }
} 