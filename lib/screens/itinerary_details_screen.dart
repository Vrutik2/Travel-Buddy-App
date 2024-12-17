import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_app/screens/activity_details_screen.dart';
import '../models/itinerary.dart';
import '../provider/firebase_provider.dart';
import 'activity_creation_screen.dart';

class ItineraryDetailScreen extends StatelessWidget {
  final String itineraryId;

  const ItineraryDetailScreen({super.key, required this.itineraryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Details'),
      ),
      body: Consumer<FirebaseProvider>(
        builder: (context, provider, child) {
          final itinerary = provider.userItineraries?.firstWhere(
            (it) => it.id == itineraryId,
            orElse: () => throw Exception('Itinerary not found'),
          );

          if (itinerary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itinerary.destination,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${itinerary.startDate.toLocal().toString().split(' ')[0]} - '
                        '${itinerary.endDate.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...itinerary.days.map((day) => _buildDayCard(context, day)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<FirebaseProvider>(
        builder: (context, provider, child) {
          final itinerary = provider.userItineraries?.firstWhere(
            (it) => it.id == itineraryId,
            orElse: () => throw Exception('Itinerary not found'),
          );

          if (itinerary == null) return Container();

          return FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select Day'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: itinerary.days.map((day) {
                          return ListTile(
                            title: Text('Day ${day.dayNumber}'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActivityCreationScreen(
                                    itineraryId: itineraryId,
                                    dayNumber: day.dayNumber,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
            tooltip: 'Add Activity',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, ItineraryDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Day ${day.dayNumber}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (day.activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No activities planned yet'),
            )
          else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: day.activities.length,
            onReorder: (int oldIndex, int newIndex) async {
              try {
                if (newIndex > oldIndex) newIndex--;
                
                await Provider.of<FirebaseProvider>(context, listen: false)
                    .reorderActivities(
                      itineraryId,
                      day.dayNumber,
                      oldIndex,
                      newIndex,
                    );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error reordering activities: $e')),
                );
              }
            },
            itemBuilder: (context, index) {
              final activity = day.activities[index];
              return ListTile(
                key: ValueKey(activity.hashCode),
                title: Text(activity.name),
                subtitle: Text(
                  '${activity.startTime.hour.toString().padLeft(2, '0')}:'
                  '${activity.startTime.minute.toString().padLeft(2, '0')} - '
                  '${activity.endTime.hour.toString().padLeft(2, '0')}:'
                  '${activity.endTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reorder),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivityDetailScreen(
                        itineraryId: itineraryId,
                        dayNumber: day.dayNumber,
                        activity: activity,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}