# Development Guide

## Getting Started

### 1. Environment Setup
Ensure you have Flutter installed and configured:
```bash
flutter doctor
```

### 2. IDE Setup
- **VS Code**: Install Flutter and Dart extensions
- **Android Studio**: Install Flutter plugin

### 3. Running the App
```bash
# Debug mode
flutter run

# Profile mode
flutter run --profile

# Release mode
flutter run --release
```

## Code Generation

This project uses code generation for JSON serialization. When you modify model classes with `@JsonSerializable()`, run:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Architecture

### State Management
- **Provider Pattern**: Used for authentication state
- **AuthProvider**: Manages authentication state and token storage

### API Layer
- **ApiService**: Centralized API calls with proper error handling
- **Automatic Authentication**: Includes X-Auth-Token in headers when available

### UI Structure
- **Screens**: Main app screens (Auth, Home, Donations, etc.)
- **Theme**: Centralized theme configuration with shadcn-inspired design
- **Components**: Reusable UI components

## Authentication Flow

1. **Initial Check**: App checks for stored authentication token
2. **WebView Login**: User logs in through official website
3. **Token Extraction**: App automatically detects authentication token
4. **Manual Fallback**: Option to manually enter token if needed
5. **Secure Storage**: Token stored securely for future use

## API Integration

All endpoints from the BDR API are implemented:

- **GET /captcha**: CAPTCHA for contact form
- **GET /v2/user/{id}**: User profile information
- **GET /v2/donations**: Blood donation history
- **GET /v2/coverages**: Blood coverage information
- **POST /contact**: Contact support form

## Testing

### Running Tests
```bash
flutter test
```

### Widget Tests
Located in `test/` directory. Add new tests for major UI components.

## Building

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Troubleshooting

### Common Issues

1. **Build Runner Issues**:
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **WebView Issues on Android**:
   - Ensure `android:usesCleartextTraffic="true"` in AndroidManifest.xml for development
   - Check internet permissions

3. **Token Storage Issues**:
   - Clear app data if authentication seems stuck
   - Check secure storage permissions

### Performance

- Use `flutter run --profile` for performance testing
- Run `flutter analyze` for code quality checks
- Use `flutter doctor` to check for issues

## Contributing

1. Follow Dart/Flutter style guidelines
2. Add tests for new features
3. Update documentation
4. Run `flutter analyze` before committing
5. Test on both Android and iOS when possible
