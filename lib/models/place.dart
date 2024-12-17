import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final LatLng location;
  final String? photoReference;
  final double? rating;
  final int? userRatingsTotal;
  final String? vicinity;
  final bool? openNow;

  Place({
    required this.id,
    required this.name,
    required this.location,
    this.photoReference,
    this.rating,
    this.userRatingsTotal,
    this.vicinity,
    this.openNow,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['place_id'],
      name: json['name'],
      location: LatLng(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
      photoReference: json['photos']?[0]?['photo_reference'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      vicinity: json['vicinity'],
      openNow: json['opening_hours']?['open_now'],
    );
  }
}