# 🚀 Render Deployment Checklist

## Pre-Deployment Setup

### 1. Google OAuth2 Configuration
- [ ] Create Google Cloud Project
- [ ] Enable Google+ API
- [ ] Create OAuth2 credentials
- [ ] Add authorized redirect URIs:
  - `https://your-app-name.onrender.com/login/oauth2/code/google`
  - `https://your-app-name.onrender.com/auth/success`
- [ ] Note down Client ID and Client Secret

### 2. GitHub Repository
- [ ] Push all backend code to GitHub
- [ ] Ensure all files are committed:
  - `build.gradle`
  - `render.yaml`
  - `Dockerfile`
  - `application.properties`
  - All Java source files

## Render Deployment Steps

### 3. Create Render Account
- [ ] Sign up at [render.com](https://render.com)
- [ ] Connect GitHub account

### 4. Create PostgreSQL Database
- [ ] Go to Render Dashboard
- [ ] Click "New +" → "PostgreSQL"
- [ ] Name: `studytrack-db`
- [ ] Database: `studytrack_db`
- [ ] User: `studytrack_user`
- [ ] Note down connection details

### 5. Create Web Service
- [ ] Click "New +" → "Web Service"
- [ ] Connect your GitHub repository
- [ ] Configure service:
  - **Name**: `studytrack-backend`
  - **Environment**: `Java`
  - **Build Command**: `./gradlew build`
  - **Start Command**: `java -jar build/libs/studytrack-backend-0.0.1-SNAPSHOT.jar`
  - **Plan**: Free (or paid for production)

### 6. Link Database
- [ ] In your web service settings
- [ ] Go to "Environment" tab
- [ ] Click "Link Database"
- [ ] Select your PostgreSQL database
- [ ] Render will auto-add database environment variables

### 7. Set Environment Variables
- [ ] Add OAuth2 credentials:
  - `GOOGLE_CLIENT_ID`: Your Google OAuth2 client ID
  - `GOOGLE_CLIENT_SECRET`: Your Google OAuth2 client secret
- [ ] Verify database variables are set (auto-added by Render):
  - `DATABASE_URL`
  - `DB_USERNAME`
  - `DB_PASSWORD`

### 8. Deploy
- [ ] Click "Create Web Service"
- [ ] Monitor build logs
- [ ] Wait for deployment to complete
- [ ] Note the service URL (e.g., `https://studytrack-backend.onrender.com`)

## Post-Deployment Verification

### 9. Test Endpoints
- [ ] Health check: `GET https://your-app.onrender.com/actuator/health`
- [ ] API test: `GET https://your-app.onrender.com/api/events`
- [ ] OAuth2 test: Visit `https://your-app.onrender.com/oauth2/authorization/google`

### 10. Update Frontend
- [ ] Update frontend API URLs to point to Render service
- [ ] Update OAuth2 redirect URIs in Google Console
- [ ] Test complete authentication flow

### 11. Monitor
- [ ] Check application logs in Render dashboard
- [ ] Monitor database connections
- [ ] Set up alerts if needed

## Troubleshooting

### Common Issues:
1. **Build fails**: Check Java version compatibility
2. **Database connection fails**: Verify environment variables
3. **OAuth2 errors**: Check redirect URIs and credentials
4. **Port issues**: Ensure PORT environment variable is set

### Useful Commands:
```bash
# Check build locally
./gradlew build

# Test database connection
./gradlew bootRun

# Check logs
tail -f logs/application.log
```

## Production Considerations

### Security:
- [ ] Use HTTPS (provided by Render)
- [ ] Set secure environment variables
- [ ] Enable CORS properly
- [ ] Implement rate limiting

### Performance:
- [ ] Consider paid plan for better performance
- [ ] Optimize database queries
- [ ] Enable caching if needed

### Monitoring:
- [ ] Set up logging aggregation
- [ ] Monitor database performance
- [ ] Set up health checks

## Support Resources

- [Render Documentation](https://render.com/docs)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) 