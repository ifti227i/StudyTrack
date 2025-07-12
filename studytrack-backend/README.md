# StudyTrack Backend

A Spring Boot backend application for the StudyTrack academic calendar and section management system.

## 🚀 Deployment on Render

### Prerequisites
- Render account
- Google OAuth2 credentials
- PostgreSQL database (provided by Render)

### Environment Variables

Set these environment variables in your Render service:

#### Required:
- `DATABASE_URL`: PostgreSQL connection string (auto-provided by Render)
- `DB_USERNAME`: Database username (auto-provided by Render)
- `DB_PASSWORD`: Database password (auto-provided by Render)

#### OAuth2 Configuration:
- `GOOGLE_CLIENT_ID`: Your Google OAuth2 client ID
- `GOOGLE_CLIENT_SECRET`: Your Google OAuth2 client secret

#### Optional:
- `PORT`: Server port (default: 8080)

### Deployment Steps

1. **Connect your GitHub repository to Render**
2. **Create a new Web Service**
3. **Configure the service:**
   - **Build Command**: `./gradlew build`
   - **Start Command**: `java -jar build/libs/studytrack-backend-0.0.1-SNAPSHOT.jar`
   - **Environment**: Java

4. **Create a PostgreSQL database:**
   - Create a new PostgreSQL database in Render
   - Link it to your web service
   - Render will automatically provide the database environment variables

5. **Set OAuth2 credentials:**
   - Go to your service's Environment tab
   - Add `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`

### Local Development

1. **Install PostgreSQL locally**
2. **Create database:**
   ```sql
   CREATE DATABASE studytrack_db;
   CREATE USER studytrack_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE studytrack_db TO studytrack_user;
   ```

3. **Set environment variables:**
   ```bash
   export DATABASE_URL=jdbc:postgresql://localhost:5432/studytrack_db
   export DB_USERNAME=studytrack_user
   export DB_PASSWORD=your_password
   export GOOGLE_CLIENT_ID=your_google_client_id
   export GOOGLE_CLIENT_SECRET=your_google_client_secret
   ```

4. **Run the application:**
   ```bash
   ./gradlew bootRun
   ```

### API Endpoints

- `GET /api/events` - Get all events
- `POST /api/events` - Create a new event
- `GET /api/events/{id}` - Get event by ID
- `PUT /api/events/{id}` - Update event
- `DELETE /api/events/{id}` - Delete event

### Database Schema

The application uses JPA/Hibernate with automatic schema generation (`ddl-auto=update`).

#### Tables:
- `events` - Calendar events
- `logins` - User authentication data
- `user_profiles` - User profile information

### Technologies Used

- **Spring Boot 3.5.3**
- **Spring Security** with OAuth2
- **Spring Data JPA** with Hibernate
- **PostgreSQL** database
- **WebSocket** support
- **Java 24**

### Security

- OAuth2 authentication with Google
- Password hashing for local accounts
- CORS configuration for frontend integration
- Input validation and sanitization

### Monitoring

- Application logs available in Render dashboard
- Health check endpoint: `/actuator/health`
- Database connection monitoring

### Troubleshooting

1. **Build fails**: Check Java version compatibility
2. **Database connection fails**: Verify environment variables
3. **OAuth2 errors**: Check Google credentials
4. **Port issues**: Ensure PORT environment variable is set correctly

### Support

For issues related to:
- **Render deployment**: Check Render documentation
- **Database**: Check PostgreSQL logs in Render
- **Application**: Check application logs in Render dashboard 