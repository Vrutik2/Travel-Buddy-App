import 'package:flutter/material.dart';
import 'travel_buddies_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back, Alex!'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Destinations',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next Trip
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('Your next Trip:'),
                subtitle: const Text('Paris, France\nDec 15-20th'),
                leading: const Icon(Icons.flight),
              ),
            ),
            const SizedBox(height: 24),

            // Popular Destinations
            const Text(
              'Popular Destinations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDestinationCard('Brazil', 'assets/images/brazil.jpg'),
                _buildDestinationCard('Japan', 'assets/images/japan.jpg'),
              ],
            ),
            const SizedBox(height: 24),

            // Navigate to Travel Buddies
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelBuddiesScreen()),
                );
              },
              child: const Text('Find Travel Buddies'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(String name, String imagePath) {
    return Expanded(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 80, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}