import 'package:flutter/material.dart';
import '../widgets/buddy_card.dart';

class TravelBuddiesScreen extends StatelessWidget {
  const TravelBuddiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> buddies = [
      {
        'name': 'Traveler 1',
        'location': 'Paris, France',
        'imageUrl': 'https://media.istockphoto.com/id/1127768734/photo/seine-in-paris.jpg?s=612x612&w=0&k=20&c=mWUbb2YkNjHZvPLMqFchZjgYPorL2tRv1HxiBxwlWgs='
      },
      {
        'name': 'Traveler 2',
        'location': 'New York, USA',
        'imageUrl': 'https://media.istockphoto.com/id/615398376/photo/new-york-city-nyc-usa.jpg?s=612x612&w=0&k=20&c=rlrsrt4jbORPDSOW5df06Ik_X_5iQo1rYQd53xSs4nw='
      },
      {
        'name': 'Traveler 3',
        'location': 'Tokyo, Japan',
        'imageUrl': 'https://media.istockphoto.com/id/1131743616/photo/aerial-view-of-tokyo-cityscape-with-fuji-mountain-in-japan.jpg?s=612x612&w=0&k=20&c=0QcSwnyzP__YpBewnQ6_-OZkn0XDtq-mXyvLSSakjZE='
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Buddies'),
      ),
      body: ListView.builder(
        itemCount: buddies.length,
        itemBuilder: (context, index) {
          final buddy = buddies[index];
          return BuddyCard(
            name: buddy['Traveler']!,
            location: buddy['Paris, France']!,
            imageUrl: buddy['https://media.istockphoto.com/id/1127768734/photo/seine-in-paris.jpg?s=612x612&w=0&k=20&c=mWUbb2YkNjHZvPLMqFchZjgYPorL2tRv1HxiBxwlWgs=']!,
            onMessage: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${buddy['name']}')),
              );
            },
          );
        },
      ),
    );
  }
}