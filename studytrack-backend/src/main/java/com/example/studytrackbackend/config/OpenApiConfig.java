package com.example.studytrackbackend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("StudyTrack API")
                .version("1.0.0")
                .description("Academic Calendar and Section Management System API")
                .contact(new Contact()
                    .name("StudyTrack Team")
                    .email("support@studytrack.com")
                    .url("https://studytrack.com"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT")))
            .servers(List.of(
                new Server()
                    .url("http://localhost:8080")
                    .description("Local Development Server"),
                new Server()
                    .url("https://studytrack-backend.onrender.com")
                    .description("Production Server")
            ));
    }
} 