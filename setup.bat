@echo off
echo Blood Donation Registry - Setup Script
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo Error: Flutter not found in PATH
    echo Please install Flutter and add it to your PATH
    echo Download from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
flutter pub get

echo.
echo Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo Checking for connected devices...
flutter devices

echo.
echo Setup complete!
echo.
echo To run the app:
echo   flutter run
echo.
echo To build APK:
echo   flutter build apk
echo.
pause
