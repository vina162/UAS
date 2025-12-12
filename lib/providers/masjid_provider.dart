import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../models/masjid_model.dart';
import '../services/masjid_service.dart';

/// Provider for managing mosque search state
class MasjidProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<MasjidModel> _masjids = [];
  LatLng? _selectedLocation;
  double _radius = 2000; // Default 2km

  // Default location (Malang, Indonesia)
  static const LatLng _defaultLocation = LatLng(-7.983908, 112.621391);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MasjidModel> get masjids => _masjids;
  LatLng? get selectedLocation => _selectedLocation ?? _defaultLocation;
  double get radius => _radius;

  /// Set selected location
  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Update search radius
  void updateRadius(double radius) {
    _radius = radius.round().toDouble();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear search results
  void clearResults() {
    _masjids.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Search for nearby mosques
  ///
  /// [lat] - Latitude (optional, uses selected location if not provided)
  /// [lng] - Longitude (optional, uses selected location if not provided)
  /// [radius] - Search radius in meters (optional, uses current radius if not provided)
  Future<void> searchMasjids({
    double? lat,
    double? lng,
    double? radius,
  }) async {
    // Use provided values or fall back to current state
    final double searchLat = lat ?? _selectedLocation?.latitude ?? _defaultLocation.latitude;
    final double searchLng = lng ?? _selectedLocation?.longitude ?? _defaultLocation.longitude;
    final double searchRadius = radius?.round().toDouble() ?? _radius;

    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call the service to search for mosques
      final List<MasjidModel> results = await MasjidService.searchMasjids(
        lat: searchLat,
        lng: searchLng,
        radius: searchRadius.toInt(),
      );

      // Update state with results
      _masjids = results;

      // Calculate distance for each mosque from the search point
      final LatLng searchPoint = LatLng(searchLat, searchLng);
      for (var masjid in _masjids) {
        final Distance distance = const Distance();
        masjid.distance = distance.as(LengthUnit.Meter, searchPoint, masjid.location).toDouble();
      }

      // Sort results by distance (nearest first)
      _masjids.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

    } catch (e) {
      // Handle errors
      _errorMessage = e.toString();
      print('Error searching mosques: $e');
    } finally {
      // Remove loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if location services are enabled and return status
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request user to enable location services
  Future<bool> requestEnableLocationService() async {
    return await Geolocator.openLocationSettings();
  }

  /// Check location permissions
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location using device GPS
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable in settings');
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedLocation = LatLng(position.latitude, position.longitude);
      debugPrint('Current location: ${position.latitude}, ${position.longitude}');

    } catch (e) {
      _errorMessage = e.toString();
      // Set to default location if getting current location fails
      _selectedLocation = _defaultLocation;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh search results with current parameters
  Future<void> refresh() async {
    if (_selectedLocation != null) {
      await searchMasjids();
    } else {
      await searchMasjids(
        lat: _defaultLocation.latitude,
        lng: _defaultLocation.longitude,
      );
    }
  }

  /// Reset provider to initial state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _masjids = [];
    _selectedLocation = null;
    _radius = 2000;
    notifyListeners();
  }
}