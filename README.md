# Masjid Near

Aplikasi Flutter untuk menemukan **masjid terdekat** berdasarkan **lokasi pengguna saat ini**. Aplikasi memanfaatkan **GPS** untuk mendapatkan koordinat pengguna dan memanggil **API publik masjidnear.me** untuk mencari masjid dalam radius tertentu, lalu menampilkan hasilnya di **peta (OpenStreetMap)** dan **daftar**.

## Preview Fitur

* Splash screen (animasi)
* Peta interaktif (OpenStreetMap)
* Marker masjid di sekitar lokasi
* Daftar masjid terdekat + jarak (meter/km)
* Pilih lokasi manual (tap peta) *(jika tersedia di implementasi)*

---

## Teknologi yang Digunakan

* **Framework**: Flutter 3.38.4
* **Language**: Dart 3.10.3
* **State Management**: Provider 6.1.1
* **Maps**: flutter_map 6.1.0 (OpenStreetMap)
* **Location Services**: geolocator 10.1.0
* **HTTP Client**: http 1.1.0
* **Fonts**: google_fonts 6.1.0

---

## Struktur Direktori

```text
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   └── masjid.dart           # Model untuk data masjid
├── services/                 # Business logic & API calls
│   └── masjid_service.dart   # Service untuk call API masjidnear.me
├── providers/                # State management
│   └── masjid_provider.dart  # Provider untuk state aplikasi
├── screens/                  # UI screens
│   ├── splash_screen.dart    # Splash screen
│   ├── map_screen.dart       # Peta + marker masjid
│   └── results_screen.dart   # List hasil pencarian masjid
└── widgets/                  # Reusable UI components
    └── masjid_card.dart      # Card info masjid
```

## Cara Kerja Aplikasi (Flow)

1. App menampilkan **SplashScreen**
2. Setelah splash, app membuka halaman utama (**MapScreen**)
3. Provider mengambil **lokasi user** via Geolocator
4. Provider memanggil **MasjidService** untuk request API
5. Response di-parse menjadi `List<Masjid>`
6. UI update otomatis via **Provider listener**
7. Marker + list masjid tampil sesuai lokasi dan radius

---

## Entry Point & Theme (main.dart)

Aplikasi menggunakan dua widget:

* `MasjidNearApp` → menampilkan `SplashScreen`
* `MasjidNearMainApp` → app utama dengan Provider + Theme + `MapScreen`

> Pastikan `SplashScreen` melakukan navigasi ke `MasjidNearMainApp` (misalnya via `Navigator.pushReplacement`) setelah animasi selesai.

---

## API Integration (MasjidNear)

Aplikasi menggunakan API publik dari [masjidnear.me](https://api.masjidnear.me/v1/masjids/search):

API yang digunakan **wajib menggunakan parameter**, jika tidak maka endpoint tidak memberikan hasil.

### Endpoint

`GET https://api.masjidnear.me/v1/masjids/search`

### Query Parameters (wajib)

* `lat` *(float)*: latitude lokasi pengguna
* `lng` *(float)*: longitude lokasi pengguna
* `rad` *(int)*: radius pencarian dalam meter

### Contoh Request

```text
https://api.masjidnear.me/v1/masjids/search?lat=-7.983908&lng=112.621391&rad=1000
```

### Catatan Penting

* Tanpa `lat`, `lng`, `rad` → API tidak bisa dipakai (tidak mengembalikan data yang valid).
* Radius `rad` disarankan: `1000`–`5000` meter.

### Response (contoh umum)

```json
{
  "data": [
    {
      "id": "string",
      "name": "string",
      "address": "string",
      "latitude": -7.9,
      "longitude": 112.6,
      "distance": 120.5,
      "phone": "string",
      "website": "string"
    }
  ]
}
```

---

## Fitur Utama

### 1) Location Services
- Mendapatkan lokasi GPS pengguna secara real-time
- Permission handling untuk Android & iOS
- Error handling ketika GPS tidak aktif atau permission denied
- Distance calculation menggunakan Haversine formula

### 2) Interactive Map (OpenStreetMap)
- OpenStreetMap dengan flutter_map
- Tap untuk memilih lokasi manual
- Markers untuk lokasi masjid yang ditemukan
- Real-time location tracking

### 3. Permission Handling
- Runtime permission request untuk location access
- Dialog prompts untuk enable GPS services
- Fallback ke manual location selection
- Settings navigation untuk permanently denied permissions

### 4) State Management dengan Provider
- Centralized state untuk masjid data
- Loading states dan error handling
- Automatic refresh functionality
- Location caching

### 5) UI Components
* Card/Widget untuk menampilkan info masjid:
  * nama
  * alamat
  * jarak

---

## Installation & Setup

### Prerequisites

* Flutter SDK >= 3.10.3
* Dart SDK >= 3.10.3
* Android Studio / Xcode untuk mobile development

### Installation Steps 

1. Clone repo
```bash
git clone <repository-url>
cd masjidnear
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate app icons (jika ingin mengubah icon)
```bash
flutter pub run flutter_launcher_icons
```

4. Jalankan aplikasi
```bash
flutter run
```

## Platform Configuration

### Android Permissions

- Location permissions di `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Permissions

- Location permissions di `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to find nearby mosques</string>
```

## Database & Data Flow

### Data Flow Architecture
1. **MasjidProvider** mengelola state aplikasi
2. **Geolocator** mendapatkan lokasi GPS user
3. **MasjidService** memanggil API dengan parameter lokasi
4. **API Response** di-parse menjadi list of Masjid objects
5. **UI Updates** secara otomatis via Provider listener

### State Management Pattern
- Location state: loading, success, error
- Masjid list state: loading, loaded, empty, error
- Selected location state: GPS location atau manual selection
- Distance calculation state: auto-update berdasarkan location

## Error Handling

### GPS Errors
- Location services disabled → Show enable dialog
- Permission denied → Request permission
- Permission permanently denied → Navigate to settings
- Location timeout → Show retry option

### API Errors
- Network timeout → Retry mechanism
- Invalid response → Show error message
- Empty results → Show no mosques found message
- API rate limit → Implement caching

## Performance Optimizations

1. **Debouncing** untuk location updates
2. **Lazy loading** untuk map tiles
3. **Memory management** untuk markers
4. **Background processing** untuk API calls
5. **State persistence** untuk selected location

## Testing Strategy

### Unit Tests
- Masjid model validation
- Distance calculation accuracy
- API response parsing

### Integration Tests
- Location service integration
- API endpoint connectivity
- State management flow

### UI Tests
- User interaction flows
- Permission dialog handling
- Map functionality testing

## Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web (PWA)
```bash
flutter build web --release
```

## Future Enhancements

1. Offline caching untuk masjid data
2. Directions integration dengan Google Maps
3. Mosque details dengan prayer times
4. User reviews dan ratings
5. Bookmark favorite mosques
6. Push notifications untuk nearby mosques

## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is licensed under the MIT License.

