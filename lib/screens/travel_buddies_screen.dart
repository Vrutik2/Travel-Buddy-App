import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TravelBuddiesScreen extends StatelessWidget {
  const TravelBuddiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Travel Buddies')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getTravelBuddies(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading buddies'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final buddies = snapshot.data ?? [];
          return ListView.builder(
            itemCount: buddies.length,
            itemBuilder: (context, index) {
              final buddy = buddies[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.black),
                  title: Text(buddy['name'] ?? 'Traveler'),
                  subtitle: Text(buddy['email'] ?? 'No email'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}