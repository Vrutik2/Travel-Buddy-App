import 'package:flutter/material.dart';

class BuddyCard extends StatelessWidget {
  final String name;
  final String location;
  final String imageUrl;
  final VoidCallback onMessage;

  const BuddyCard({
    super.key,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 24,
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(location),
        trailing: ElevatedButton(
          onPressed: onMessage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[100],
            foregroundColor: Colors.green[900],
          ),
          child: const Text('Message'),
        ),
      ),
    );
  }
}