# ==============================================================================
# Zero Grid: Quantum Shift (txa.zerogrid.quantumshift) - Production Release Build Script
# Tác giả: TXA Studio
# Usage:
#   .\build_release.ps1 apk            -> Builds Signed Release APK
#   .\build_release.ps1 aab            -> Builds Signed Release AAB (Google Play Store)
#   .\build_release.ps1 all (hoặc 1)   -> Builds cả APK & AAB xuất ra thư mục production
# ==============================================================================

param (
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

# Đảm bảo script chạy từ thư mục gốc của dự án
Set-Location -Path $PSScriptRoot

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# 0. Chuẩn bị thư mục đầu ra thống nhất 'production'
$prodDir = Join-Path $PSScriptRoot "production"
if (-not (Test-Path $prodDir)) {
    New-Item -ItemType Directory -Path $prodDir -Force | Out-Null
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "🚀 STARTING ZERO GRID: QUANTUM SHIFT PRODUCTION BUILD PROCESS..." -ForegroundColor Yellow
Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host "Unified Production Directory: $prodDir" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# 1. Đồng bộ và cài đặt packages
Write-Host "`n📦 [1/4] Running flutter pub get..." -ForegroundColor Gray
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch packages!" -ForegroundColor Red
    exit 1
}

# 2. Kiểm thử tự động (Unit Tests)
Write-Host "`n🧪 [2/4] Running flutter test..." -ForegroundColor Gray
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Unit tests failed! Please fix failing tests before building release." -ForegroundColor Red
    exit 1
}

$buildApk = ($Target -eq "apk" -or $Target -eq "all" -or $Target -eq "1" -or $Target -eq "")
$buildAab = ($Target -eq "aab" -or $Target -eq "all" -or $Target -eq "1" -or $Target -eq "")

# 3. Build APK có chữ ký số Keystore
if ($buildApk) {
    Write-Host "`n📱 [3/4] Building Signed Release APK..." -ForegroundColor Green
    flutter build apk --release
    if ($LASTEXITCODE -eq 0) {
        $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkPath) {
            $apkDest = Join-Path $prodDir "Zero Grid Setup.apk"
            Copy-Item -Path $apkPath -Destination $apkDest -Force
            $apkSize = (Get-Item $apkDest).Length / 1MB
            Write-Host "✅ Release APK built & signed successfully!" -ForegroundColor Green
            Write-Host "   Output Path: $apkDest" -ForegroundColor White
            Write-Host "   File Size:   $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Failed to build Release APK!" -ForegroundColor Red
        exit 1
    }
}

# 4. Build AAB (Android App Bundle tải lên Google Play Console)
if ($buildAab) {
    Write-Host "`n📦 [4/4] Building Signed Release AAB (Google Play Store Bundle)..." -ForegroundColor Green
    flutter build appbundle --release
    if ($LASTEXITCODE -eq 0) {
        $aabPath = "build\app\outputs\bundle\release\app-release.aab"
        if (Test-Path $aabPath) {
            $aabDest = Join-Path $prodDir "Zero Grid Setup.aab"
            Copy-Item -Path $aabPath -Destination $aabDest -Force
            $aabSize = (Get-Item $aabDest).Length / 1MB
            Write-Host "✅ Release AAB built & signed successfully!" -ForegroundColor Green
            Write-Host "   Output Path: $aabDest" -ForegroundColor White
            Write-Host "   File Size:   $([math]::Round($aabSize, 2)) MB" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Failed to build Release AAB!" -ForegroundColor Red
        exit 1
    }
}

# 5. Đồng bộ Google Play Store Assets và tài liệu hướng dẫn vào production folder
Write-Host "`n📋 Copying Play Store Assets & Guidelines to production/..." -ForegroundColor Gray
if (Test-Path "PLAY_CONSOLE_GUIDE.md") {
    Copy-Item -Path "PLAY_CONSOLE_GUIDE.md" -Destination (Join-Path $prodDir "PLAY_CONSOLE_GUIDE.md") -Force
}
if (Test-Path "supabase_schema_zero_grid.sql") {
    Copy-Item -Path "supabase_schema_zero_grid.sql" -Destination (Join-Path $prodDir "supabase_schema_zero_grid.sql") -Force
}
if (Test-Path "google_play_assets") {
    $destAssets = Join-Path $prodDir "google_play_assets"
    Copy-Item -Path "google_play_assets" -Destination $destAssets -Recurse -Force
}

$Stopwatch.Stop()
$elapsed = $Stopwatch.Elapsed
if ($elapsed.TotalSeconds -ge 60) {
    $timeStr = "$($elapsed.Minutes) phút $($elapsed.Seconds) giây"
} else {
    $timeStr = "$($elapsed.Seconds) giây"
}

Write-Host "`n⏱ Total Build Time: $timeStr" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "📂 ALL PRODUCTION ARTIFACTS IN '$prodDir':" -ForegroundColor Yellow
Get-ChildItem -Path $prodDir | ForEach-Object {
    if ($_.PSIsContainer) {
        Write-Host "   📂 $($_.Name) (Directory)" -ForegroundColor White
    } else {
        $size = $_.Length / 1MB
        Write-Host "   📄 $($_.Name) ($([math]::Round($size, 2)) MB)" -ForegroundColor White
    }
}
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "🎉 PRODUCTION BUILD COMPLETED READY FOR GOOGLE PLAY SUBMISSION!" -ForegroundColor Green
