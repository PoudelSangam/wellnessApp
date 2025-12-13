# Wellness App - Setup Script

Write-Host "🚀 Setting up Wellness App..." -ForegroundColor Cyan

# Check Flutter installation
Write-Host "`n📋 Checking Flutter installation..." -ForegroundColor Yellow
flutter --version

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter is not installed. Please install Flutter first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter is installed" -ForegroundColor Green

# Navigate to project directory
Set-Location -Path $PSScriptRoot

# Clean previous builds
Write-Host "`n🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "`n📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed" -ForegroundColor Green

# Run build runner for JSON serialization
Write-Host "`n🔧 Running build runner..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

# Check for connected devices
Write-Host "`n📱 Checking for connected devices..." -ForegroundColor Yellow
flutter devices

# Analyze code
Write-Host "`n🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze

Write-Host "`n✨ Setup complete!" -ForegroundColor Green
Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Update backend URL in lib/core/constants/api_constants.dart"
Write-Host "   2. Run 'flutter run' to start the app"
Write-Host "   3. Check README.md for detailed documentation"
Write-Host "`nHappy coding! 🎉" -ForegroundColor Magenta
