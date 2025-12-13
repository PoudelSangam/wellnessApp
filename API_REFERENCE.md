# 🔌 API Reference - Wellness App

## Base URL Configuration

**File**: `lib/core/constants/api_constants.dart`
```dart
static const String baseUrl = 'http://your-backend-url.com';
```

---

## 🔐 Authentication Endpoints

### 1. Login
**Endpoint**: `POST /api/login/`

**Request**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Response** (200 OK):
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Errors**:
- 400: Invalid credentials
- 401: Unauthorized

---

### 2. Signup
**Endpoint**: `POST /api/signup/`

**Request**:
```json
{
  "email": "user@example.com",
  "username": "john_doe",
  "password": "securePass123",
  "age": 25,
  "gender": "Male",
  "height": 175.5,
  "weight": 70.0,
  "self_reported_stress": "Moderate",
  "gad7_score": 8,
  "physical_activity_week": 3,
  "importance_stress_reduction": "High",
  "primary_goal": "Reduce Stress",
  "workout_goal_days": 5
}
```

**Response** (201 Created):
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "john_doe",
    ...
  }
}
```

**Errors**:
- 400: Validation error
- 409: Username/email already exists

---

### 3. Token Refresh
**Endpoint**: `POST /api/token/refresh/`

**Request**:
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response** (200 OK):
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Errors**:
- 401: Invalid or expired refresh token

---

## 👤 User Endpoints

### 4. Get User Profile
**Endpoint**: `GET /api/user/profile/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "username": "john_doe",
  "age": 25,
  "gender": "Male",
  "height": 175.5,
  "weight": 70.0,
  "self_reported_stress": "Moderate",
  "gad7_score": 8,
  "physical_activity_week": 3,
  "importance_stress_reduction": "High",
  "primary_goal": "Reduce Stress",
  "workout_goal_days": 5
}
```

**Errors**:
- 401: Unauthorized

---

### 5. Update User Profile
**Endpoint**: `PUT /api/user/update/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Request** (partial update allowed):
```json
{
  "age": 26,
  "weight": 68.0,
  "self_reported_stress": "Low",
  "workout_goal_days": 6
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "email": "user@example.com",
  ...updated fields...
}
```

**Errors**:
- 400: Validation error
- 401: Unauthorized

---

### 6. Delete Account
**Endpoint**: `DELETE /api/user/delete/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (204 No Content)

**Errors**:
- 401: Unauthorized

---

## 🏃 Activity Endpoints

### 7. Get Activity Recommendations
**Endpoint**: `GET /api/workout/recommend/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "recommendations": [
    {
      "id": "1",
      "name": "Deep Breathing Exercise",
      "description": "Calm your mind with focused breathing",
      "category": "Breathing",
      "duration": 10,
      "difficulty": "Easy",
      "benefits": [
        "Reduces stress",
        "Improves focus",
        "Lowers heart rate"
      ],
      "image_url": "https://example.com/image.jpg",
      "video_url": "https://example.com/video.mp4",
      "instructions": [
        "Find a comfortable position",
        "Breathe in slowly for 4 counts",
        "Hold for 4 counts",
        "Exhale for 4 counts"
      ]
    }
  ]
}
```

**Errors**:
- 401: Unauthorized

---

### 8. Get All Activities
**Endpoint**: `GET /api/activities/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters** (optional):
- `category`: Filter by category (e.g., "Mental", "Physical")
- `difficulty`: Filter by difficulty (e.g., "Easy", "Medium", "Hard")
- `page`: Pagination page number
- `limit`: Items per page

**Example**: `/api/activities/?category=Mental&difficulty=Easy`

**Response** (200 OK):
```json
{
  "count": 100,
  "next": "/api/activities/?page=2",
  "previous": null,
  "activities": [
    {
      "id": "1",
      "name": "Meditation Session",
      "description": "10-minute guided meditation",
      "category": "Mental",
      "duration": 10,
      "difficulty": "Easy",
      "benefits": ["Reduces anxiety", "Improves focus"],
      "image_url": "https://example.com/image.jpg"
    }
  ]
}
```

**Errors**:
- 401: Unauthorized

---

### 9. Get Activity Detail
**Endpoint**: `GET /api/activities/:id/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "id": "1",
  "name": "Deep Breathing Exercise",
  "description": "Detailed description...",
  "category": "Breathing",
  "duration": 10,
  "difficulty": "Easy",
  "benefits": [
    "Reduces stress",
    "Improves focus"
  ],
  "image_url": "https://example.com/image.jpg",
  "video_url": "https://example.com/video.mp4",
  "instructions": [
    "Step 1: Find a comfortable position",
    "Step 2: Close your eyes",
    "Step 3: Breathe deeply"
  ]
}
```

**Errors**:
- 401: Unauthorized
- 404: Activity not found

---

### 10. Complete Activity
**Endpoint**: `POST /api/activities/complete/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Request**:
```json
{
  "activity_id": "1",
  "notes": "Felt very relaxed after this session"
}
```

**Response** (201 Created):
```json
{
  "id": "completion_uuid",
  "activity_id": "1",
  "activity_name": "Deep Breathing Exercise",
  "completed_at": "2024-12-13T10:30:00Z",
  "duration": 10,
  "notes": "Felt very relaxed after this session"
}
```

**Errors**:
- 400: Invalid activity_id
- 401: Unauthorized

---

## 📊 Progress Endpoints

### 11. Get Completed Activities History
**Endpoint**: `GET /api/progress/history/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters** (optional):
- `start_date`: Filter from date (YYYY-MM-DD)
- `end_date`: Filter to date (YYYY-MM-DD)
- `category`: Filter by category

**Response** (200 OK):
```json
{
  "history": [
    {
      "id": "completion_uuid",
      "activity_id": "1",
      "activity_name": "Deep Breathing Exercise",
      "completed_at": "2024-12-13T10:30:00Z",
      "duration": 10,
      "notes": "Felt relaxed"
    }
  ]
}
```

**Errors**:
- 401: Unauthorized

---

### 12. Get Weekly Statistics
**Endpoint**: `GET /api/progress/weekly/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "week_start": "2024-12-11",
  "week_end": "2024-12-17",
  "completed_this_week": 5,
  "completed_today": 2,
  "streak": 7,
  "goal_days": 5,
  "completion_rate": 0.8,
  "activities_by_category": {
    "Mental": 3,
    "Physical": 2
  },
  "daily_breakdown": [
    {
      "date": "2024-12-11",
      "count": 1,
      "completed": true
    },
    {
      "date": "2024-12-12",
      "count": 2,
      "completed": true
    }
  ]
}
```

**Errors**:
- 401: Unauthorized

---

### 13. Get Monthly Statistics
**Endpoint**: `GET /api/progress/monthly/`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "month": "2024-12",
  "total_completed": 25,
  "total_minutes": 300,
  "average_per_week": 6,
  "most_active_category": "Mental",
  "activities_by_category": {
    "Mental": 15,
    "Physical": 10
  },
  "weekly_breakdown": [
    {
      "week": 1,
      "count": 6
    },
    {
      "week": 2,
      "count": 7
    }
  ]
}
```

**Errors**:
- 401: Unauthorized

---

## 🔑 Authentication Flow

```
1. User logs in with username/password
   ↓
2. Backend returns access token + refresh token
   ↓
3. App stores tokens securely
   ↓
4. All API requests include: Authorization: Bearer <access_token>
   ↓
5. If 401 error received:
   - Send refresh token to /api/token/refresh/
   - Get new access token
   - Retry original request
   ↓
6. If refresh fails:
   - Logout user
   - Redirect to login
```

---

## 📝 Field Specifications

### Stress Levels
- "Low"
- "Moderate"
- "High"
- "Very High"

### Gender Options
- "Male"
- "Female"
- "Other"
- "Prefer not to say"

### Activity Categories
- "Mental"
- "Physical"
- "Breathing"
- "Meditation"
- "Yoga"
- "Stretching"

### Difficulty Levels
- "Easy"
- "Medium"
- "Hard"

### Primary Goals
- "Reduce Stress"
- "Improve Fitness"
- "Better Sleep"
- "Mental Clarity"
- "Weight Management"
- "Overall Wellness"

### Importance Levels
- "Low"
- "Medium"
- "High"
- "Very High"

### Numeric Constraints
- Age: 13-120
- Height: 50-300 (cm)
- Weight: 20-500 (kg)
- GAD-7 Score: 0-21
- Physical Activity Days: 0-7
- Workout Goal Days: 0-7

---

## ⚠️ Error Response Format

All error responses follow this format:

```json
{
  "error": "Error message here",
  "message": "Detailed error description",
  "status_code": 400,
  "field_errors": {
    "username": ["This field is required"],
    "email": ["Invalid email format"]
  }
}
```

---

## 🛡️ Security Notes

1. **Always use HTTPS in production**
2. **Never log tokens in production**
3. **Tokens expire after 24 hours** (access)
4. **Refresh tokens expire after 7 days**
5. **Rate limiting**: 100 requests per minute per user

---

## 📞 Need Help?

- Check backend API documentation
- Review error messages carefully
- Test endpoints with Postman/Thunder Client
- Verify authentication headers
- Check token expiration

---

**Happy API Integration! 🚀**
