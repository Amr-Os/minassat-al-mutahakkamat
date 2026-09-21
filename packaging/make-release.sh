#!/bin/bash
# Builds the release bundle, tarball and .deb package into dist/.
# Usage: ./packaging/make-release.sh   (run from the repo root)
set -e
cd "$(dirname "$0")/.."

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
APP=minassat-al-mutahakkamat

flutter build linux

rm -rf dist
mkdir -p dist

# --- tarball: extract anywhere and run ./minassat-al-mutahakkamat ---
cp -r build/linux/x64/release/bundle "dist/$APP"
tar -czf "dist/${APP}-${VERSION}-linux-x86_64.tar.gz" -C dist "$APP"

# --- .deb: installs to /opt + launcher entry + icon ---
DEB="dist/${APP}_${VERSION}_amd64"
mkdir -p "$DEB/opt/$APP" \
  "$DEB/usr/share/applications" \
  "$DEB/usr/share/icons/hicolor/256x256/apps" \
  "$DEB/DEBIAN"
cp -r build/linux/x64/release/bundle/* "$DEB/opt/$APP/"
cp "packaging/$APP.desktop" "$DEB/usr/share/applications/"
cp assets/logo.png "$DEB/usr/share/icons/hicolor/256x256/apps/$APP.png"
cat > "$DEB/DEBIAN/control" <<EOF
Package: $APP
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libevdev2
Maintainer: Amr-Os <https://github.com/Amr-Os>
Description: حول هاتفك إلى متحكم للحاسوب
 نافذة واحدة تدير كل الهواتف المتصلة كأجهزة تحكم افتراضية
 (واجهة عربية، بروتوكول Colfer عبر TCP، حقن uinput).
EOF
dpkg-deb --build "$DEB"
rm -rf "dist/$APP" "$DEB"

echo "Release artifacts:"
ls -la dist/
