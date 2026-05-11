#!/bin/bash
set -e

APP="护眼助手"
BUNDLE="/Applications/$APP.app"

echo "== 编译 Swift..."

xcrun swiftc \
  -o "build/EyeRestApp" \
  "main.swift" \
  -framework Cocoa \
  -framework WebKit \
  -O

echo "== 创建 .app 包..."

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp "build/EyeRestApp" "$BUNDLE/Contents/MacOS/EyeRestApp"
cp "Info.plist" "$BUNDLE/Contents/Info.plist"
cp "../widget.html" "$BUNDLE/Contents/Resources/widget.html"

chmod +x "$BUNDLE/Contents/MacOS/EyeRestApp"

echo "✅ 安装完成: $BUNDLE"
