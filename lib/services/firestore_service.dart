import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/itinerary.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile Methods
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  // Itinerary Methods
  Future<String> createItinerary(Itinerary itinerary) async {
    final doc = await _firestore.collection('itineraries').add(itinerary.toMap());
    return doc.id;
  }

  Future<List<Itinerary>> getUserItineraries(String userId) async {
    final snapshot = await _firestore
        .collection('itineraries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Itinerary.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateItinerary(Itinerary itinerary) async {
    await _firestore
        .collection('itineraries')
        .doc(itinerary.id)
        .update(itinerary.toMap());
  }

  Future<void> deleteItinerary(String itineraryId) async {
    await _firestore.collection('itineraries').doc(itineraryId).delete();
  }

  // Travel Buddy Methods
  Stream<List<UserProfile>> getPotentialTravelBuddies(
    String userId,
    List<String> interests,
  ) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: userId)
        .where('interests', arrayContainsAny: interests)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList());
  }
}