import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/masjid_provider.dart';
import 'results_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentRadius = 2000; // Default 2km

  @override
  Widget build(BuildContext context) {
    return Consumer<MasjidProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mosque, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Text('Masjid Near'),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: provider.selectedLocation ?? const LatLng(-7.983908, 112.621391),
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    // Update selected location when user taps on map
                    provider.setSelectedLocation(point);
                    _showLocationSnackbar(context, point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.masjidnear.app',
                  ),

                  // Marker for selected location
                  MarkerLayer(
                    markers: [
                      if (provider.selectedLocation != null)
                        Marker(
                          point: provider.selectedLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF059669),
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Floating control panel
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Radius control
                        Text(
                          'Search Radius',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Radius value display
                        Text(
                          _currentRadius < 1000
                              ? '${(_currentRadius / 1000).toStringAsFixed(1)} km'
                              : '${(_currentRadius / 1000).toStringAsFixed(0)} km',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),

                        // Radius slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF059669),
                            inactiveTrackColor: const Color(0xFF059669).withOpacity(0.2),
                            thumbColor: const Color(0xFF059669),
                            overlayColor: const Color(0xFF059669).withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _currentRadius,
                            min: 1000, // 1km
                            max: 20000, // 20km
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                _currentRadius = value.round().toDouble();
                              });
                              provider.updateRadius(_currentRadius);
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Search button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    await provider.searchMasjids(
                                      lat: provider.selectedLocation?.latitude,
                                      lng: provider.selectedLocation?.longitude,
                                      radius: _currentRadius,
                                    );

                                    if (!provider.isLoading && provider.errorMessage == null) {
                                      // Navigate to results screen
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ResultsScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: provider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: Text(
                              provider.isLoading ? 'Searching...' : 'Search Nearby Mosques',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Use current location button
              Positioned(
                bottom: 100,
                right: 16,
                child: Consumer<MasjidProvider>(
                  builder: (context, provider, child) {
                    return FloatingActionButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              await _handleLocationButtonPress(context, provider);
                            },
                      backgroundColor: Colors.white,
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Color(0xFF059669),
                            ),
                    );
                  },
                ),
              ),

              // Loading overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF059669),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Searching for nearby mosques...',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error message
              if (provider.errorMessage != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: GoogleFonts.inter(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: provider.clearError,
                            icon: const Icon(Icons.close),
                            color: Colors.red[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationSnackbar(BuildContext context, LatLng point) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location selected: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle location button press with proper error handling
  Future<void> _handleLocationButtonPress(BuildContext context, MasjidProvider provider) async {
    // Check if location services are enabled
    bool serviceEnabled = await provider.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Show dialog to enable location services
      if (context.mounted) {
        bool shouldOpenSettings = await _showEnableLocationDialog(context);

        if (shouldOpenSettings) {
          // Try to open location settings
          bool opened = await provider.requestEnableLocationService();

          if (opened) {
            // Wait a bit for user to enable GPS
            await Future.delayed(const Duration(seconds: 2));

            // Check again
            serviceEnabled = await provider.isLocationServiceEnabled();
          }
        }
      } else {
        return;
      }
    }

    // Check permissions
    LocationPermission permission = await provider.checkLocationPermission();
    if (permission == LocationPermission.denied) {
      permission = await provider.requestLocationPermission();

      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showPermissionPermanentlyDeniedDialog(context);
      }
      return;
    }

    // Get current location
    await provider.getCurrentLocation();

    // Show message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage != null
                ? provider.errorMessage!
                : 'Location updated successfully',
          ),
          backgroundColor: provider.errorMessage != null
              ? Colors.red
              : const Color(0xFF059669),
        ),
      );

      // Move map to new location
      if (provider.errorMessage == null && provider.selectedLocation != null) {
        _mapController.move(provider.selectedLocation!, 15.0);
      }
    }
  }

  /// Show dialog to enable location services
  Future<bool> _showEnableLocationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_disabled,
                color: Colors.orange[700],
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Enable Location Services',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'Location services are disabled. Please enable GPS to find nearby mosques.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.gps_fixed, size: 16),
                    label: const Text('Enable GPS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                color: Colors.red[600],
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Location Permission Required',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'This app needs location permission to find nearby mosques. Please grant permission to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show permission permanently denied dialog
  void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: Colors.red[600],
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Permission Permanently Denied',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'Location permission is permanently denied. Please enable it in app settings to use this feature.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}