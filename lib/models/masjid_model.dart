import 'package:latlong2/latlong.dart';

/// Model class for representing a Mosque/Masjid
class MasjidModel {
  /// Name of the mosque
  final String masjidName;

  /// Address description
  final String address;

  /// Location coordinates (latitude, longitude)
  final LatLng location;

  /// Distance from search point (in meters)
  double? distance;

  MasjidModel({
    required this.masjidName,
    required this.address,
    required this.location,
    this.distance,
  });

  /// Create MasjidModel from JSON response
  factory MasjidModel.fromJson(Map<String, dynamic> json) {
    // Extract coordinates from the nested structure
    final List<dynamic> coordinates = json['masjidLocation']['coordinates'];
    final double longitude = coordinates[0].toDouble();
    final double latitude = coordinates[1].toDouble();

    // Extract address from nested structure
    final String address = json['masjidAddress']?['description'] ?? 'Address not available';

    return MasjidModel(
      masjidName: json['masjidName'] ?? 'Unknown Mosque',
      address: address,
      location: LatLng(latitude, longitude),
    );
  }

  /// Convert to JSON (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'masjidName': masjidName,
      'address': address,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'distance': distance,
    };
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distance == null) return 'Unknown distance';

    if (distance! < 1000) {
      return '${distance!.round()} m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Get Google Maps URL for this location
  String get googleMapsUrl {
    return 'https://www.google.com/maps?q=${location.latitude},${location.longitude}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasjidModel &&
        other.masjidName == masjidName &&
        other.address == address &&
        other.location == location;
  }

  @override
  int get hashCode => masjidName.hashCode ^ address.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'MasjidModel{masjidName: $masjidName, address: $address, location: $location, distance: $distance}';
  }
}