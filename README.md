# Wellness App - Flutter Project

A comprehensive wellness and mental health application with personalized activity recommendations.

## Features

### ✅ Phase 1: Authentication & User Onboarding
- ✅ Login with username and password
- ✅ Multi-step signup process
- ✅ Secure token storage using `flutter_secure_storage`
- ✅ Automatic token refresh
- ✅ Form validation

### ✅ Phase 2: Core App Structure & UI
- ✅ Beautiful Material Design 3 UI
- ✅ Bottom Navigation (Dashboard, Activity, Profile)
- ✅ Provider state management
- ✅ Responsive design
- ✅ Custom theme with gradients

### ✅ Phase 3: Activity & Recommendation Engine
- ✅ Personalized activity recommendations
- ✅ Activity categories (Mental, Physical, Breathing, etc.)
- ✅ Activity details with benefits and instructions
- ✅ Complete activities tracking
- ✅ Progress history

### ✅ Phase 4: Enhancements
- ✅ Notification service (local notifications)
- ✅ Dashboard with wellness summary
- ✅ Progress tracking (daily, weekly, monthly)
- ✅ Motivational quotes
- ✅ Profile management
- ✅ Loading states and error handling

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── routes/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── dashboard/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── activity/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── home/
│   │   └── screens/
│   └── splash/
│       └── screens/
└── main.dart
```

## Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK / Xcode

### Steps

1. **Clone or navigate to the project directory:**
   ```bash
   cd "c:\Users\ACER\Desktop\clz major project\App"
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update Backend URL:**
   - Open `lib/core/constants/api_constants.dart`
   - Update `baseUrl` with your backend API URL:
     ```dart
     static const String baseUrl = 'http://your-backend-url.com';
     ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Backend API Endpoints

The app expects the following API endpoints:

### Authentication
- `POST /api/login/` - Login with username and password
- `POST /api/signup/` - Create new account
- `POST /api/token/refresh/` - Refresh access token

### User
- `GET /api/user/profile/` - Get user profile
- `PUT /api/user/update/` - Update user profile
- `DELETE /api/user/delete/` - Delete account

### Activities
- `GET /api/workout/recommend/` - Get recommended activities
- `GET /api/activities/` - Get all activities (optional: ?category=Mental)
- `GET /api/activities/:id/` - Get activity details
- `POST /api/activities/complete/` - Mark activity as completed

### Progress
- `GET /api/progress/history/` - Get completed activities history
- `GET /api/progress/weekly/` - Get weekly statistics
- `GET /api/progress/monthly/` - Get monthly statistics

## Configuration

### Android Notifications
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS Notifications
Notifications are automatically requested when the app starts.

## State Management

The app uses **Provider** for state management with the following providers:

- `AuthProvider` - Authentication and user state
- `DashboardProvider` - Dashboard data and statistics
- `ActivityProvider` - Activities and recommendations
- `ProfileProvider` - Profile management

## Security

- Access tokens stored securely using `flutter_secure_storage`
- Automatic token refresh before expiry
- Secure API communication with headers
- Input validation on all forms

## UI/UX Features

- **Material Design 3** with custom theme
- **Gradient backgrounds** for visual appeal
- **Smooth animations** and transitions
- **Pull-to-refresh** on data screens
- **Loading states** with shimmer effects
- **Error handling** with user-friendly messages
- **Empty states** with helpful messages
- **Progress indicators** for user engagement

## Color Scheme

- Primary Color: `#6C63FF` (Purple)
- Secondary Color: `#00D4AA` (Teal)
- Accent Color: `#FF6584` (Pink)
- Success Color: `#00B894` (Green)
- Error Color: `#E74C3C` (Red)

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Issue: Dependencies not installing
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Notifications not working
**Solution:**
- Check permissions in device settings
- Ensure notification service is initialized in main.dart
- Verify AndroidManifest.xml has notification permissions

## Future Enhancements

- [ ] Social features (share progress, challenges)
- [ ] Integration with fitness trackers
- [ ] Video tutorials for activities
- [ ] AI-powered recommendations
- [ ] Gamification (badges, achievements)
- [ ] Offline mode with local caching
- [ ] Multi-language support
- [ ] Dark mode toggle
- [ ] Export progress reports

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support, please contact: your-email@example.com

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- Community packages used in this project

---

**Happy Coding! 🚀**
