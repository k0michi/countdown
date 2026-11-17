#!/bin/zsh
# Builds Countdown.app (a menu bar-only app) into ./build.
# The version comes from `git describe`: "1.2.3" on an x.y.z tag,
# "1.2.3-4-gabc1234" after it, "abc1234" with no tag, plus "-dirty"
# when there are uncommitted changes.
set -euo pipefail
cd "$(dirname "$0")"

VERSION="$(git describe --tags --match '[0-9]*.[0-9]*.[0-9]*' --always --dirty)"

swift build -c release

APP=build/Countdown.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Countdown" "$APP/Contents/MacOS/Countdown"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>Countdown</string>
    <key>CFBundleIdentifier</key><string>com.koyomiji.countdown</string>
    <key>CFBundleName</key><string>Countdown</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP ($VERSION)"
