import 'package:flutter/material.dart';
import 'package:travel_buddy_app/screens/activity_editing_screen.dart';
import '../models/itinerary.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String itineraryId;
  final int dayNumber;
  final Activity activity;

  const ActivityDetailScreen({
    super.key,
    required this.itineraryId,
    required this.dayNumber,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActivityEditScreen(
                    itineraryId: itineraryId,
                    dayNumber: dayNumber,
                    activity: activity,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(activity.name),
                subtitle: Text(
                  '${activity.startTime.hour.toString().padLeft(2, '0')}:'
                  '${activity.startTime.minute.toString().padLeft(2, '0')} - '
                  '${activity.endTime.hour.toString().padLeft(2, '0')}:'
                  '${activity.endTime.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(activity.notes!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
