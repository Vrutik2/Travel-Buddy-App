import 'package:flutter/material.dart';
import '../widgets/destination_card.dart';

class DestinationsScreen extends StatelessWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Destinations'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: 4, // Replace with dynamic list length
        itemBuilder: (context, index) {
          return DestinationCard(
            title: 'Destination ${index + 1}',
            imageUrl: 'https://via.placeholder.com/200', // Replace with real image URLs
            onTap: () {
              // Handle destination click
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clicked Destination ${index + 1}')),
              );
            },
          );
        },
      ),
    );
  }
}