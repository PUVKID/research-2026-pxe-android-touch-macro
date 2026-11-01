$ErrorActionPreference = 'Stop'
$source18 = 'D:\2026\PXE Project\18차\source'
$bridge18 = 'D:\2026\PXE18Build'
$delivery18 = 'D:\2026\PXE Project\18차'
$sourceLink18 = Get-Item -LiteralPath (Join-Path $bridge18 'source')
if ($sourceLink18.LinkType -ne 'Junction' -or $sourceLink18.Target -ne $source18) { throw '18차 전용 빌드 연결을 확인하세요.' }
$env:JAVA_HOME = Join-Path $bridge18 'tools\jdk-17.0.20.1+1'
$env:ANDROID_HOME = Join-Path $bridge18 'android\android-sdk'
$env:NEX_SIGNING_DIR = (Join-Path $bridge18 'signing').Replace('\','/')
if (!(Test-Path -LiteralPath (Join-Path $env:NEX_SIGNING_DIR 'macro.jks'))) { throw '기존 앱과 같은 개인 서명 키가 필요합니다.' }
[IO.File]::WriteAllText((Join-Path $source18 'local.properties'), 'sdk.dir='+$env:ANDROID_HOME.Replace('\','/'), [Text.UTF8Encoding]::new($false))
Push-Location (Join-Path $bridge18 'source')
try {
    $gradle18 = Join-Path $bridge18 'tools\gradle-8.13\bin\gradle.bat'
    & $gradle18 :app:assembleRelease :app:testDebugUnitTest :app:lintDebug --console=plain --no-watch-fs --no-daemon --project-cache-dir work/.gradle
    if ($LASTEXITCODE -ne 0) { throw '휴대전화 APK 빌드 또는 검사 실패' }
    Copy-Item -LiteralPath (Join-Path $source18 'work\build\app\outputs\apk\release\app-release.apk') -Destination (Join-Path $delivery18 'PXE_18차_v1.8_노트10플러스.apk')
    & $gradle18 :app:assembleRelease :app:assembleReleaseAndroidTest -PNEX_PC --console=plain --no-watch-fs --no-daemon --project-cache-dir work/.gradle
    if ($LASTEXITCODE -ne 0) { throw 'PC APK 또는 기기 검사 APK 빌드 실패' }
    Copy-Item -LiteralPath (Join-Path $source18 'work\build\app\outputs\apk\release\app-release.apk') -Destination (Join-Path $delivery18 'PXE_18차_v1.8_PC용.apk')
} finally { Pop-Location }
Write-Host '완료: 18차 폴더에 휴대전화용과 PC용 APK를 저장했습니다.'
