# Flutter Wellness App - Quick Start Guide

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Android device/emulator or iOS simulator

## Setup Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Backend URL**
   - Open: `lib/core/constants/api_constants.dart`
   - Update: `baseUrl = 'http://your-backend-url.com'`

3. **Run the App**
   ```bash
   flutter run
   ```

## Key Features

### Authentication
- Login with username/password
- Multi-step signup (4 steps)
- Automatic token refresh
- Secure storage

### Dashboard
- Daily wellness summary
- Weekly/monthly progress
- Activity recommendations
- Motivational quotes

### Activities
- Browse by category
- View recommendations
- See activity details
- Track completions

### Profile
- View/edit personal info
- Update wellness goals
- Manage account settings
- Logout

## App Navigation

```
Splash Screen
    ↓
Login / Signup
    ↓
Home (Bottom Navigation)
    ├── Dashboard
    ├── Activity
    │   └── Activity Detail
    └── Profile
        └── Edit Profile
```

## API Integration

### Required Endpoints

**Auth**
- POST `/api/login/`
- POST `/api/signup/`
- POST `/api/token/refresh/`

**User**
- GET `/api/user/profile/`
- PUT `/api/user/update/`

**Activities**
- GET `/api/workout/recommend/`
- GET `/api/activities/`
- GET `/api/activities/:id/`
- POST `/api/activities/complete/`

**Progress**
- GET `/api/progress/history/`
- GET `/api/progress/weekly/`
- GET `/api/progress/monthly/`

## Request/Response Examples

### Login Request
```json
{
  "username": "user123",
  "password": "password123"
}
```

### Login Response
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Signup Request
```json
{
  "email": "user@example.com",
  "username": "user123",
  "password": "password123",
  "age": 25,
  "gender": "Male",
  "height": 175,
  "weight": 70,
  "self_reported_stress": "Moderate",
  "gad7_score": 8,
  "physical_activity_week": 3,
  "importance_stress_reduction": "High",
  "primary_goal": "Reduce Stress",
  "workout_goal_days": 5
}
```

### Activity Recommendation Response
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

## Troubleshooting

### Build Issues
```bash
flutter clean
flutter pub get
```

### Code Generation Issues
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependencies Conflicts
```bash
flutter pub upgrade
```

## Testing

### Run on Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Build APK
```bash
flutter build apk --release
```

## State Management

Using **Provider** pattern:
- AuthProvider - User authentication
- DashboardProvider - Dashboard data
- ActivityProvider - Activities & recommendations
- ProfileProvider - Profile management

## Security Notes

- Tokens stored in secure storage
- API requests use Bearer token auth
- Automatic token refresh on 401
- Form validation on all inputs

## UI Customization

Colors in `lib/core/theme/app_theme.dart`:
```dart
primaryColor: Color(0xFF6C63FF)
secondaryColor: Color(0xFF00D4AA)
accentColor: Color(0xFFFF6584)
```

## Need Help?

Check the main README.md for detailed documentation.

---

**Ready to build! 🚀**
