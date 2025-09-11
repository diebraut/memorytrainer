#!/usr/bin/env bash
set -e
SRC="icon-1024.png"
mkdir -p AppIcon.appiconset
# iPhone
sips -Z 180 "$SRC" --out AppIcon.appiconset/Icon-App-60x60@3x.png
sips -Z 120 "$SRC" --out AppIcon.appiconset/Icon-App-60x60@2x.png
sips -Z 120 "$SRC" --out AppIcon.appiconset/Icon-Spotlight-40x40@3x.png
sips -Z 80  "$SRC" --out AppIcon.appiconset/Icon-Spotlight-40x40@2x.png
sips -Z 60  "$SRC" --out AppIcon.appiconset/Icon-Notification-20x20@3x.png
sips -Z 40  "$SRC" --out AppIcon.appiconset/Icon-Notification-20x20@2x.png
sips -Z 87  "$SRC" --out AppIcon.appiconset/Icon-Settings-29x29@3x.png
sips -Z 58  "$SRC" --out AppIcon.appiconset/Icon-Settings-29x29@2x.png
# iPad
sips -Z 167 "$SRC" --out AppIcon.appiconset/Icon-iPad-83.5x83.5@2x.png
sips -Z 152 "$SRC" --out AppIcon.appiconset/Icon-iPad-76x76@2x.png
sips -Z 80  "$SRC" --out AppIcon.appiconset/Icon-iPad-Spotlight-40x40@2x.png
sips -Z 40  "$SRC" --out AppIcon.appiconset/Icon-iPad-Notification-20x20@2x.png
sips -Z 58  "$SRC" --out AppIcon.appiconset/Icon-iPad-Settings-29x29@2x.png
echo "Done. Drop AppIcon.appiconset into Assets.xcassets"
