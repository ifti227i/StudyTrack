package com.example.studytrackbackend.controller;

import com.example.studytrackbackend.entity.Login;
import com.example.studytrackbackend.entity.LoginRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private LoginRepository loginRepository;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @PostMapping("/signup")
    public String signup(@RequestBody Login login) {
        if (loginRepository.findByEmail(login.getEmail()) != null) {
            return "Email already exists";
        }
        if (loginRepository.findByUsername(login.getUsername()) != null) {
            return "Username already exists";
        }
        login.setPassword(passwordEncoder.encode(login.getPassword()));
        loginRepository.save(login);
        return "Signup successful";
    }

    @PostMapping("/signin")
    public String signin(@RequestBody Login login) {
        Login existing = loginRepository.findByEmail(login.getEmail());
        if (existing == null) {
            return "Invalid email or password";
        }
        if (!passwordEncoder.matches(login.getPassword(), existing.getPassword())) {
            return "Invalid email or password";
        }
        return "Signin successful";
    }
} 