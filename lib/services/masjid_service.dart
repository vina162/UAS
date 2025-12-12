import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/masjid_model.dart';

/// Service class for handling API communication with Masjid Near API
class MasjidService {
  static const String _baseUrl = 'https://api.masjidnear.me/v1/masjids/search'; //API ini membutuhkan parameter, jadi kalau langsung dibuka akan error.
  static const Duration _timeout = Duration(seconds: 30);

  /// Search for nearby mosques based on location and radius
  ///
  /// [lat] - Latitude coordinate
  /// [lng] - Longitude coordinate
  /// [radius] - Search radius in meters (default: 2000)
  ///
  /// Returns a list of MasjidModel objects
  /// Throws an Exception on failure
  static Future<List<MasjidModel>> searchMasjids({
    required double lat,
    required double lng,
    int radius = 2000,
  }) async {
    try {
      // Build the URL with query parameters
      final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'lat': lat.toString(), //Latitude (garis lintang)
        'lng': lng.toString(), //Longitude (garis bujur)
        'rad': radius.toString(), //Radius pencarian (meter)
      });

      print('Searching mosques at: $lat, $lng with radius: $radius meters');

      // Make the GET request with timeout
      final http.Response response = await http.get(uri).timeout(_timeout);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if data exists and contains masjids
        if (data.containsKey('data') && data['data'] != null) {
          final List<dynamic> masjidsJson = data['data']['masjids'] ?? [];

          // Convert JSON to MasjidModel objects
          final List<MasjidModel> masjids = masjidsJson
              .map((json) => MasjidModel.fromJson(json))
              .toList();

          print('Found ${masjids.length} mosques');
          return masjids;
        } else {
          throw Exception('Invalid response format: missing data');
        }
      } else {
        // Handle different HTTP status codes
        String errorMessage = 'Request failed with status: ${response.statusCode}';

        if (response.statusCode == 400) {
          errorMessage = 'Invalid request parameters';
        } else if (response.statusCode == 404) {
          errorMessage = 'API endpoint not found';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error occurred';
        }

        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      // Handle network connection errors
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Handle other errors (JSON parsing, timeout, etc.)
      if (e is Exception) {
        // Re-throw if it's already an Exception
        rethrow;
      } else {
        // Wrap unknown errors
        throw Exception('An unexpected error occurred: $e');
      }
    }
  }

  /// Test API connectivity
  /// Returns true if API is reachable, false otherwise
  static Future<bool> testConnection() async {
    try {
      // Use Malang coordinates for testing
      final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'lat': '-7.983908',
        'lng': '112.621391',
        'rad': '1000',
      });

      final http.Response response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}