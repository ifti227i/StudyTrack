# 📚 StudyTrack - Academic Calendar & Section Management System

A comprehensive fullstack application for managing academic calendars, events, and student sections with real-time updates and Google OAuth2 authentication.

## 🏗️ Architecture

- **Frontend**: Flutter (Android, iOS, Web)
- **Backend**: Spring Boot 3.5.3 with Java 24
- **Database**: PostgreSQL
- **Authentication**: Google OAuth2
- **Real-time**: WebSocket
- **Deployment**: Render

## 🚀 Features

### Core Features
- 📅 **Academic Calendar Management**
- 👥 **Section Management** (Student/Teacher roles)
- 📝 **Event Creation & Management**
- 🔐 **Google OAuth2 Authentication**
- 📊 **User Statistics & Profiles**
- 🔔 **Real-time Updates**

### User Types
- **Student**: View events, join sections, limited permissions
- **Teacher**: Create events, manage sections, full permissions
- **Personal**: Custom events, no section restrictions

## 📁 Project Structure

```
fullstack_2/
├── lib/                          # Flutter frontend
│   ├── general/                  # Shared components
│   ├── student/                  # Student profile
│   ├── teacher/                  # Teacher profile
│   └── personal/                 # Personal profile
├── studytrack-backend/           # Spring Boot backend
│   ├── src/main/java/
│   │   └── com/example/studytrackbackend/
│   │       ├── config/           # Configuration classes
│   │       ├── controller/       # REST controllers
│   │       ├── entity/           # JPA entities
│   │       └── exception/        # Custom exceptions
│   └── src/main/resources/
│       └── db/migration/         # Database migrations
└── android/                      # Android-specific files
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK 3.8.1+
- Java 24
- PostgreSQL
- Google Cloud Console account

### Backend Setup
1. Navigate to backend directory:
   ```bash
   cd studytrack-backend
   ```

2. Set environment variables:
   ```bash
   export DATABASE_URL=postgresql://user:pass@host:port/db
   export GOOGLE_CLIENT_ID=your_google_client_id
   export GOOGLE_CLIENT_SECRET=your_google_client_secret
   ```

3. Run the application:
   ```bash
   ./gradlew bootRun
   ```

### Frontend Setup
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

## 🌐 API Documentation

Once the backend is running, visit:
- **Swagger UI**: `http://localhost:8080/swagger-ui.html`
- **Health Check**: `http://localhost:8080/api/health`
- **API Docs**: `http://localhost:8080/api-docs`

## 🚀 Deployment

### Render Deployment
1. Push to GitHub
2. Connect repository to Render
3. Set environment variables in Render dashboard
4. Deploy automatically

### Environment Variables for Render
```bash
DATABASE_URL=postgresql://user:pass@host:port/db
DB_USERNAME=your_db_username
DB_PASSWORD=your_db_password
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

## 📊 Database Schema

### Tables
- **events**: Academic events and activities
- **sections**: Student sections and departments
- **logins**: User authentication and profiles
- **user_profiles**: Extended user information

### Key Features
- Automatic audit trails
- Foreign key relationships
- Performance indexes
- Data integrity constraints

## 🔧 Development

### Backend Development
- Spring Boot 3.5.3
- JPA/Hibernate
- Spring Security
- WebSocket support
- Actuator monitoring

### Frontend Development
- Flutter 3.8.1
- Material Design
- Google Sign-In
- Real-time updates
- Responsive design

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For support and questions, please contact the development team.
