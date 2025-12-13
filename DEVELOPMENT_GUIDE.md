# 🛠️ Development Guide - Wellness App

## Getting Started

### Initial Setup
```powershell
# Clone/Navigate to project
cd "c:\Users\ACER\Desktop\clz major project\App"

# Run setup script (Windows)
.\setup.ps1

# Or manually
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Development Workflow

### 1. Configure Backend
**File**: `lib/core/constants/api_constants.dart`
```dart
static const String baseUrl = 'http://your-backend-url.com';
```

### 2. Run the App
```bash
# Check available devices
flutter devices

# Run on device
flutter run

# Run with hot reload
flutter run --hot

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### 3. Common Commands
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Code Structure

### Adding a New Feature

1. **Create Feature Folder**
```
lib/features/my_feature/
  ├── models/
  ├── providers/
  ├── screens/
  └── widgets/
```

2. **Create Model** (if needed)
```dart
// lib/features/my_feature/models/my_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  
  MyModel({required this.id, required this.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) => 
      _$MyModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

3. **Generate Model Code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Create Provider**
```dart
// lib/features/my_feature/providers/my_provider.dart
import 'package:flutter/material.dart';

class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    
    // Fetch data...
    
    _isLoading = false;
    notifyListeners();
  }
}
```

5. **Create Screen**
```dart
// lib/features/my_feature/screens/my_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Consumer<MyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Content'));
        },
      ),
    );
  }
}
```

6. **Add to Router**
```dart
// lib/core/routes/app_router.dart
GoRoute(
  path: '/my-feature',
  builder: (context, state) => const MyScreen(),
),
```

7. **Register Provider**
```dart
// lib/main.dart
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
)
```

## API Integration

### Making API Calls

```dart
// In your provider
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class MyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Future<void> fetchData() async {
    try {
      final response = await _apiService.get(
        '/api/endpoint/',
        headers: ApiConstants.getHeaders(token: 'your-token'),
      );
      
      // Process response
      print(response);
    } on ApiException catch (e) {
      print('Error: ${e.message}');
    }
  }
}
```

### Handling Authenticated Requests

```dart
// Get token from AuthProvider
final authProvider = context.read<AuthProvider>();
final token = authProvider.accessToken;

final response = await _apiService.get(
  '/api/protected-endpoint/',
  headers: ApiConstants.getHeaders(token: token),
);
```

### Handling 401 (Token Expired)

```dart
try {
  final response = await _apiService.get(endpoint);
} on ApiException catch (e) {
  if (e.statusCode == 401) {
    // Refresh token
    await authProvider.refreshAccessToken();
    // Retry request
    return fetchData();
  }
}
```

## State Management

### Using Provider

**1. Read (one-time)**
```dart
final value = context.read<MyProvider>().value;
```

**2. Watch (rebuild on change)**
```dart
final value = context.watch<MyProvider>().value;
```

**3. Consumer (specific widget)**
```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.value);
  },
)
```

### Best Practices

- Use `read` for callbacks/actions
- Use `watch` for UI that needs updates
- Use `Consumer` for specific widgets
- Don't call `notifyListeners()` during build

## UI Development

### Creating Custom Widgets

```dart
// lib/features/my_feature/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const MyWidget({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
```

### Using Theme

```dart
// Access theme colors
Theme.of(context).primaryColor
Theme.of(context).colorScheme.secondary

// Access text styles
Theme.of(context).textTheme.headlineMedium
Theme.of(context).textTheme.bodyLarge

// Custom colors from AppTheme
AppTheme.primaryColor
AppTheme.successColor
```

### Common Layouts

**Card with Padding**
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Content
      ],
    ),
  ),
)
```

**List with Dividers**
```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

**Loading State**
```dart
if (isLoading)
  const Center(child: CircularProgressIndicator())
else
  // Content
```

## Navigation

### Using GoRouter

**Navigate to route**
```dart
context.push('/path');
context.go('/path'); // Replace
```

**Navigate with parameters**
```dart
context.push('/detail/${item.id}');
```

**Go back**
```dart
context.pop();
context.pop(result); // With result
```

**Pass data**
```dart
// In router
GoRoute(
  path: '/detail/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return DetailScreen(id: id);
  },
)
```

## Debugging

### Print Debugging
```dart
import '../../../core/utils/logger.dart';

Logger.info('Information');
Logger.debug('Debug message');
Logger.warning('Warning');
Logger.error('Error occurred');
Logger.success('Success!');
```

### Flutter DevTools
```bash
# Open DevTools
flutter pub global run devtools
```

### Common Issues

**Issue**: Hot reload not working
**Solution**: Try hot restart (R) or restart app

**Issue**: Dependencies not found
**Solution**: `flutter clean && flutter pub get`

**Issue**: Build errors
**Solution**: `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: Navigation not working
**Solution**: Check route paths and GoRouter configuration

## Testing

### Unit Tests
```dart
// test/providers/my_provider_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Provider test', () {
    final provider = MyProvider();
    expect(provider.isLoading, false);
  });
}
```

### Widget Tests
```dart
// test/widgets/my_widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test', (tester) async {
    await tester.pumpWidget(MyWidget());
    expect(find.text('Title'), findsOneWidget);
  });
}
```

## Performance Tips

1. **Use const constructors**
```dart
const Text('Hello')
const SizedBox(height: 16)
```

2. **Avoid rebuilds**
```dart
// Use Consumer for specific widgets
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.value);
  },
)
```

3. **Lazy load lists**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

4. **Cache network images**
```dart
Image.network(url, cacheHeight: 200)
```

## Building for Production

### Android Release Build
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release

# Output location
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build
```bash
flutter build ios --release

# Then open in Xcode for App Store submission
open ios/Runner.xcworkspace
```

### Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Update app name and icons
- [ ] Configure signing (Android/iOS)
- [ ] Test on physical devices
- [ ] Check API endpoints (production URLs)
- [ ] Remove debug code/logs
- [ ] Test all features
- [ ] Check permissions
- [ ] Review privacy policy
- [ ] Prepare store listings

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Add my feature"

# Push to remote
git push origin feature/my-feature

# Merge to main
git checkout main
git merge feature/my-feature
```

## Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)

## Support

For issues or questions:
1. Check existing documentation
2. Search Flutter issues on GitHub
3. Ask on Stack Overflow
4. Contact team lead

---

**Happy Developing! 🚀**
