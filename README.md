# Blood Donation Registry App

A Flutter application for interacting with the Blood Donation Registry API in Greece. This app provides a modern, shadcn UI-inspired interface for all available API endpoints.

## Features

### 🔐 Authentication
- **WebView Authentication**: Seamlessly login through the official service.bdr.gr website
- **Manual Token Entry**: Option to manually enter X-Auth-Token if automatic detection fails
- **Secure Token Storage**: Tokens are securely stored using `flutter_secure_storage`
- **Auto Token Detection**: Automatically detects authentication tokens from the WebView

### 📊 Dashboard
- **Modern UI**: Clean, card-based interface inspired by shadcn design system
- **Quick Navigation**: Easy access to all features from the main dashboard
- **Real-time Status**: Shows authentication status and user information

### 🩸 Blood Donations
- **Donation History**: View your complete blood donation history
- **Detailed Information**: See donation dates, locations, blood types, and hemoglobin levels
- **Status Tracking**: Visual status indicators for each donation
- **Pull to Refresh**: Easy data refresh with pull-down gesture

### 🏥 Blood Coverages
- **Coverage Information**: View available blood coverage data
- **Location Details**: See coverage locations and types
- **Date Ranges**: View start and end dates for coverages
- **Status Indicators**: Visual status chips for each coverage

### 👤 User Profile
- **User Information**: View detailed user profile data
- **Medical Info**: See blood type, total donations, and last donation date
- **Contact Details**: View email and phone information
- **Flexible User ID**: Enter any user ID to view profile information

### 📞 Contact Support
- **Support Form**: Send messages to the support team
- **CAPTCHA Integration**: Built-in captcha verification
- **Form Validation**: Comprehensive form validation
- **File Attachments**: Support for including additional information

## API Endpoints Covered

1. **GET /captcha** - Get captcha data (no authentication required)
2. **GET /v2/user/{id}** - Get user information (requires X-Auth-Token)
3. **GET /v2/donations** - Get donation history (requires X-Auth-Token)
4. **GET /v2/coverages** - Get blood coverages (requires X-Auth-Token)
5. **POST /contact** - Send support message (no authentication required)

## Installation & Setup

### Prerequisites
- Flutter SDK (2.19.0 or higher)
- Android Studio or VS Code
- Android device/emulator or iOS device/simulator

### Quick Setup
1. **Clone or download** this project
2. **Run the setup script**:
   ```powershell
   # PowerShell
   .\setup.ps1
   
   # Or Command Prompt
   setup.bat
   ```

### Manual Setup
If you prefer manual setup or the script doesn't work:

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate JSON serialization code**:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Check connected devices**:
   ```bash
   flutter devices
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Building for Production
- **Android APK**: `flutter build apk`
- **Android AAB**: `flutter build appbundle`
- **iOS**: `flutter build ios`

## Development Setup

### VS Code Setup
This project includes VS Code configuration files:
- `.vscode/tasks.json` - Flutter tasks (build, run, clean)
- `.vscode/launch.json` - Debug configurations
- `.vscode/settings.json` - Project settings

### Available VS Code Tasks
- **Flutter: Get Packages** - Install dependencies
- **Flutter: Run** - Run the app in debug mode
- **Flutter: Build APK** - Build production APK
- **Flutter: Generate Code** - Run code generation
- **Flutter: Clean** - Clean build files

### Running the App
1. **Debug Mode**: Press `F5` or use "Flutter: Debug" launch configuration
2. **Terminal**: Run `flutter run` in the project directory
3. **VS Code**: Use Command Palette → "Flutter: Run"

## Project Structure

3. **Run the App**
   ```powershell
   flutter run
   ```

## How to Use

### 1. Authentication
1. Launch the app
2. You'll be presented with a WebView of service.bdr.gr
3. Log in with your credentials
4. The app will automatically detect your X-Auth-Token
5. If automatic detection fails, use the key icon to manually enter your token

### 2. Getting Your X-Auth-Token Manually
If you need to get your token manually:
1. Open service.bdr.gr in your browser
2. Log in to your account
3. Open Developer Tools (F12)
4. Go to Network tab
5. Make a request (refresh page or navigate)
6. Look for the `X-Auth-Token` header in the requests
7. Copy the token value and paste it in the app

### 3. Using the App
Once authenticated:
- **Dashboard**: Overview of all features
- **Donations**: View your donation history
- **Coverages**: Browse blood coverage information
- **Profile**: View user profile (enter user ID)
- **Contact**: Send messages to support

## Example API Usage

The app demonstrates how to use the Blood Donation Registry API:

```bash
# Example API request (as shown in the documentation)
curl -v -X GET -H "X-Auth-Token: TOKEN_HERE" "https://service.blooddonorregistry.gr/v2/donations"
```

The app handles all API requests automatically with proper authentication headers.

## UI Design

The app features a modern design inspired by shadcn/ui:
- **Clean Cards**: All content is presented in clean, bordered cards
- **Consistent Colors**: Professional color scheme with proper contrast
- **Loading States**: Skeleton loaders and loading indicators
- **Error Handling**: User-friendly error messages and retry options
- **Responsive Layout**: Works well on different screen sizes

## Error Handling

The app includes comprehensive error handling:
- **Network Errors**: Handles connection issues gracefully
- **Authentication Errors**: Clear messaging for auth failures
- **API Errors**: Displays meaningful error messages from the API
- **Validation Errors**: Form validation with helpful hints

## Security

- **Secure Storage**: Authentication tokens are stored securely
- **HTTPS Only**: All API calls use HTTPS
- **Token Validation**: Automatic token validation and refresh prompts
- **Input Sanitization**: All user inputs are properly validated

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational and demonstration purposes. Please ensure compliance with the Blood Donation Registry terms of service when using their API.

## Support

For issues with the app, please check:
1. Your internet connection
2. Your authentication token validity
3. The API documentation at https://athinab.github.io/bdr-api-docs/

For API-specific issues, contact the Blood Donation Registry support team through the app's contact form.
