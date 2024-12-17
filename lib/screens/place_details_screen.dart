// lib/screens/place_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_app/models/place.dart';
import '../services/places_service.dart';
import '../provider/firebase_provider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailsScreen({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final PlacesService _placesService = PlacesService();
  List<String> _photoReferences = [];
  bool _loadingPhotos = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _loadingPhotos = true);
    try {
      _photoReferences = await _placesService.getPlacePhotos(widget.place.id);
    } catch (e) {
      print('Error loading photos: $e');
    } finally {
      setState(() => _loadingPhotos = false);
    }
  }

  void _addToItinerary(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<FirebaseProvider>(
          builder: (context, provider, child) {
            final itineraries = provider.userItineraries;
            
            if (itineraries == null || itineraries.isEmpty) {
              return AlertDialog(
                title: Text('No Itineraries'),
                content: Text('Create an itinerary first to add places.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                String? selectedItineraryId;
                int? selectedDay;
                TimeOfDay? startTime;
                TimeOfDay? endTime;

                return AlertDialog(
                  title: Text('Add to Itinerary'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Itinerary',
                            border: OutlineInputBorder(),
                          ),
                          items: itineraries.map((itinerary) {
                            return DropdownMenuItem(
                              value: itinerary.id,
                              child: Text(itinerary.destination),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedItineraryId = value;
                              selectedDay = null;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        if (selectedItineraryId != null) ...[
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Day',
                              border: OutlineInputBorder(),
                            ),
                            items: itineraries
                                .firstWhere((it) => it.id == selectedItineraryId)
                                .days
                                .map((day) {
                              return DropdownMenuItem(
                                value: day.dayNumber,
                                child: Text('Day ${day.dayNumber}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            title: Text('Start Time'),
                            subtitle: Text(startTime?.format(context) ?? 'Select'),
                            leading: Icon(Icons.access_time),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  startTime = time;
                                  if (endTime == null) {
                                    endTime = TimeOfDay(
                                      hour: time.hour + 1,
                                      minute: time.minute,
                                    );
                                  }
                                });
                              }
                            },
                          ),
                          SizedBox(height: 8),
                          ListTile(
                            title: Text('End Time'),
                            subtitle: Text(endTime?.format(context) ?? 'Select'),
                            leading: Icon(Icons.access_time),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: endTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => endTime = time);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: selectedItineraryId != null &&
                              selectedDay != null &&
                              startTime != null &&
                              endTime != null
                          ? () async {
                              try {
                                final itinerary = itineraries.firstWhere(
                                  (it) => it.id == selectedItineraryId,
                                );
                                final dayDate = itinerary.startDate
                                    .add(Duration(days: selectedDay! - 1));

                                await provider.addPlaceToItinerary(
                                  selectedItineraryId!,
                                  selectedDay!,
                                  widget.place,
                                  DateTime(
                                    dayDate.year,
                                    dayDate.month,
                                    dayDate.day,
                                    startTime!.hour,
                                    startTime!.minute,
                                  ),
                                  DateTime(
                                    dayDate.year,
                                    dayDate.month,
                                    dayDate.day,
                                    endTime!.hour,
                                    endTime!.minute,
                                  ),
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${widget.place.name} to itinerary!',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding to itinerary: $e'),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loadingPhotos)
              Container(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_photoReferences.isNotEmpty)
              Container(
                height: 200,
                child: PageView.builder(
                  itemCount: _photoReferences.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      _placesService.getPhotoUrl(_photoReferences[index]),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50),
                        );
                      },
                    );
                  },
                ),
              )
            else if (widget.place.photoReference != null)
              Image.network(
                _placesService.getPhotoUrl(widget.place.photoReference!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 50),
                  );
                },
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.place.rating != null) ...[
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          '${widget.place.rating} (${widget.place.userRatingsTotal} reviews)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                  if (widget.place.vicinity != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.place.vicinity!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                  if (widget.place.openNow != null) ...[
                    Row(
                      children: [
                        Icon(
                          widget.place.openNow!
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.place.openNow! ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.place.openNow! ? 'Open Now' : 'Closed',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                  if (_photoReferences.isNotEmpty)
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photoReferences.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                // Open photo viewer
                              },
                              child: Image.network(
                                _placesService.getPhotoUrl(_photoReferences[index]),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _addToItinerary(context),
                    icon: Icon(Icons.add),
                    label: Text('Add to Itinerary'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}