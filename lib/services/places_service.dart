import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_buddy_app/models/place.dart';

class PlacesService {
  static const String apiKey = 'AIzaSyAsQfWVX-O4ieRchovoEv4gI58ZwmXgbRM';
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<Place>> getNearbyPlaces(LatLng location, {int radius = 1500}) async {
    final url = '$baseUrl/nearbysearch/json?'
        'location=${location.latitude},${location.longitude}'
        '&radius=$radius'
        '&type=tourist_attraction'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['results'] as List)
              .map((place) => Place.fromJson(place))
              .toList();
        }
      }
      throw Exception('Failed to load places');
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }

  Future<List<Place>> searchPlaces(String query, LatLng location) async {
    final url = '$baseUrl/textsearch/json?'
        'query=$query'
        '&location=${location.latitude},${location.longitude}'
        '&radius=50000'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['results'] as List)
              .map((place) => Place.fromJson(place))
              .toList();
        }
      }
      throw Exception('Failed to search places');
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  Future<List<String>> getPlacePhotos(String placeId) async {
    final url = '$baseUrl/details/json?'
        'place_id=$placeId'
        '&fields=photos'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result']['photos'] != null) {
          return (data['result']['photos'] as List)
              .map((photo) => photo['photo_reference'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching photos: $e');
      return [];
    }
  }

  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$baseUrl/photo?'
        'maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }
}