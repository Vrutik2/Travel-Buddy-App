import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _userInterests = [];
  bool _isInitialized = false;

  List<String> get userInterests => _userInterests;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await loadUserInterests();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('App provider initialization error: $e');
    }
  }

  Future<void> loadUserInterests() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists && doc.data()?['interests'] != null) {
          _userInterests = List<String>.from(doc.data()!['interests']);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Load user interests error: $e');
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'interests': interests});
        _userInterests = interests;
        notifyListeners();
      }
    } catch (e) {
      print('Update user interests error: $e');
    }
  }
}