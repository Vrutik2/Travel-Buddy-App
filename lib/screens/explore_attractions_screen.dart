import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_buddy_app/models/place.dart';
import 'dart:async';
import '../services/places_service.dart';
import 'place_details_screen.dart';

class ExploreAttractionsScreen extends StatefulWidget {
  @override
  _ExploreAttractionsScreenState createState() => _ExploreAttractionsScreenState();
}

class _ExploreAttractionsScreenState extends State<ExploreAttractionsScreen> {
  final PlacesService _placesService = PlacesService();
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Place> _nearbyPlaces = [];
  bool _isLoading = false;
  LatLng? _currentLocation;
  bool _showList = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      if (_currentLocation != null) {
        _loadNearbyPlaces();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchPlaces(query);
      } else {
        _loadNearbyPlaces();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentLocation == null) return;

    setState(() => _isLoading = true);
    try {
      _nearbyPlaces = await _placesService.searchPlaces(query, _currentLocation!);
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyPlaces() async {
    if (_currentLocation == null) return;

    setState(() => _isLoading = true);
    try {
      _nearbyPlaces = await _placesService.getNearbyPlaces(_currentLocation!);
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = _nearbyPlaces.map((place) {
        return Marker(
          markerId: MarkerId(place.id),
          position: place.location,
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.vicinity,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailsScreen(place: place),
              ),
            );
          },
        );
      }).toSet();

      if (_currentLocation != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'You are here'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Attractions'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _currentLocation == null
                    ? Center(child: Text('Unable to get location'))
                    : _showList
                        ? ListView.builder(
                            itemCount: _nearbyPlaces.length,
                            itemBuilder: (context, index) {
                              final place = _nearbyPlaces[index];
                              return ListTile(
                                title: Text(place.name),
                                subtitle: Text(place.vicinity ?? ''),
                                trailing: place.rating != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 20),
                                          Text('${place.rating}'),
                                        ],
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaceDetailsScreen(place: place),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLocation!,
                              zoom: 14,
                            ),
                            onMapCreated: (controller) => _mapController = controller,
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
          ),
        ],
      ),
      floatingActionButton: !_showList
          ? FloatingActionButton(
              onPressed: _loadNearbyPlaces,
              child: Icon(Icons.refresh),
              tooltip: 'Refresh Places',
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
