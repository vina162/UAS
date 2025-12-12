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

* Mengambil lokasi GPS user
* Handling permission (request/deny/permanently denied)
* Menampilkan pesan error jika GPS mati atau permission ditolak

### 2) Interactive Map (OpenStreetMap)

* Map tiles dari OpenStreetMap melalui `flutter_map`
* Marker untuk lokasi masjid
* Dapat menampilkan lokasi user (opsional sesuai implementasi)

### 3) State Management (Provider)

* Menyimpan state:

  * lokasi user
  * radius pencarian
  * list masjid
  * loading & error state
* UI update otomatis ketika data berubah

### 4) UI Components

* Card/Widget untuk menampilkan info masjid:

  * nama
  * alamat
  * jarak

---

## Installation & Setup

### Prerequisites

* Flutter SDK >= 3.10.3
* Dart SDK >= 3.10.3
* Android Studio / Xcode

### Steps

1. Clone repo

```bash
git clone <repository-url>
cd masjidnear
```

2. Install dependencies

```bash
flutter pub get
```

3. Jalankan aplikasi

```bash
flutter run
```

---

## Platform Configuration

### Android Permissions

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Permissions

`ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to find nearby mosques</string>
```

---

## Build / Deployment

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

---

## Future Enhancements

* Offline caching hasil masjid
* Rute/directions ke masjid (Google Maps / OSRM)
* Prayer times & detail masjid
* Bookmark masjid favorit
* Review & rating

---

## License

MIT License
