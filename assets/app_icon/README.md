# App Icon Instructions

## Icon Requirements
To replace the app icon, you need to create icons in the following sizes:

### Android Icons
Create icons in `android/app/src/main/res/` folders:
- `mipmap-hdpi/ic_launcher.png` - 72×72px
- `mipmap-mdpi/ic_launcher.png` - 48×48px
- `mipmap-xhdpi/ic_launcher.png` - 96×96px
- `mipmap-xxhdpi/ic_launcher.png` - 144×144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192×192px

### iOS Icons
Create icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- `Icon-App-20×20@1x.png` - 20×20px
- `Icon-App-20×20@2x.png` - 40×40px
- `Icon-App-20×20@3x.png` - 60×60px
- `Icon-App-29×29@1x.png` - 29×29px
- `Icon-App-29×29@2x.png` - 58×58px
- `Icon-App-29×29@3x.png` - 87×87px
- `Icon-App-40×40@1x.png` - 40×40px
- `Icon-App-40×40@2x.png` - 80×80px
- `Icon-App-40×40@3x.png` - 120×120px
- `Icon-App-60×60@2x.png` - 120×120px
- `Icon-App-60×60@3x.png` - 180×180px
- `Icon-App-76×76@1x.png` - 76×76px
- `Icon-App-76×76@2x.png` - 152×152px
- `Icon-App-83.5×83.5@2x.png` - 167×167px
- `Icon-1024×1024@1x.png` - 1024×1024px

## Icon Design Suggestions
For Masjid Near app, consider using:
- Mosque silhouette icon
- Green and white color scheme (#059669, #FFFFFF)
- Islamic geometric patterns
- Compass or location pin with mosque

## Quick Setup with Flutter Launcher Icons Plugin
1. Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/app_icon/icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/app_icon/icon.png"
    background_color: "#hexcode"
    theme_color: "#hexcode"
  windows:
    generate: true
    image_path: "assets/app_icon/icon.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/app_icon/icon.png"
```

2. Create a 1024×1024px icon as `assets/app_icon/icon.png`

3. Run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## Icon Resources
- [Flaticon](https://www.flaticon.com/search?word=mosque) - Free mosque icons
- [Material Icons](https://fonts.google.com/icons) - Google Material icons
- [Iconfinder](https://www.iconfinder.com/search?q=mosque) - Premium and free icons
- [Canva](https://www.canva.com/) - Easy icon creation tool

## Recommended Icon Style
- **Primary Color**: #059669 (Emerald Green)
- **Secondary Color**: #FFFFFF (White)
- **Tertiary Color**: #D4AF37 (Gold)
- **Shape**: Rounded square or circle
- **Content**: Mosque dome/minaret or compass + mosque combination