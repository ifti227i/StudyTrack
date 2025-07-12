package com.example.studytrack.studytrack_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.example.studytrackbackend")
public class StudytrackBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(StudytrackBackendApplication.class, args);
	}

}
