# Blood Donation Registry - Setup Script
Write-Host "Blood Donation Registry - Setup Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    flutter --version
    if ($LASTEXITCODE -ne 0) { throw }
} catch {
    Write-Host "Error: Flutter not found in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter and add it to your PATH" -ForegroundColor Red
    Write-Host "Download from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Generating code..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

Write-Host ""
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To run the app:" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "To build APK:" -ForegroundColor Cyan
Write-Host "  flutter build apk" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
