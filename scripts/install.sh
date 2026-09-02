#!/bin/zsh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MacTuck"
BUNDLE_ID="com.grosucon.mactuck"
IDENTITY="MacTuck Dev"
INSTALL_ROOT="$HOME/Applications"
APP_PATH="$INSTALL_ROOT/$APP_NAME.app"
VERSION="$(date +%Y.%m.%d)"

cd "$PROJECT_ROOT"

echo "==> Building"
swift build -c release --product "$APP_NAME" 2>&1 | tail -1
BIN_DIR="$(swift build -c release --product "$APP_NAME" --show-bin-path)"

echo "==> Stopping running instance"
pkill -x "$APP_NAME" 2>/dev/null || true

echo "==> Assembling $APP_PATH"
mkdir -p "$INSTALL_ROOT"
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
cp "$BIN_DIR/$APP_NAME" "$APP_PATH/Contents/MacOS/$APP_NAME"

cat > "$APP_PATH/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>      <string>en</string>
    <key>CFBundleDisplayName</key>            <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>             <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>             <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>  <string>6.0</string>
    <key>CFBundleName</key>                   <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>            <string>APPL</string>
    <key>CFBundleShortVersionString</key>     <string>$VERSION</string>
    <key>CFBundleVersion</key>                <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>         <string>14.0</string>
    <key>LSUIElement</key>                    <true/>
    <key>NSHighResolutionCapable</key>        <true/>
</dict>
</plist>
PLIST

if security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
  echo "==> Signing with '$IDENTITY'"
  codesign --force --sign "$IDENTITY" --identifier "$BUNDLE_ID" "$APP_PATH"
else
  echo "==> WARNING: no '$IDENTITY' identity; ad-hoc signing. Run ./scripts/make-cert.sh once,"
  echo "    otherwise every rebuild invalidates the Accessibility grant."
  codesign --force --sign - --identifier "$BUNDLE_ID" "$APP_PATH"
fi

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "$APP_PATH" >/dev/null 2>&1 || true

echo "==> Launching"
open "$APP_PATH"
echo "Installed $APP_PATH. Logs: log stream --predicate 'subsystem == \"$BUNDLE_ID\"' --level debug"
