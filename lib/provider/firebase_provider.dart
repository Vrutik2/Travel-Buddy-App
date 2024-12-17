import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy_app/models/place.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../models/itinerary.dart';
import '../constants/app_constants.dart';

class FirebaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _userInterests = [];
  List<Itinerary>? _userItineraries;
  bool _isInitialized = false;

  List<String> get userInterests => _userInterests;
  List<Itinerary>? get userItineraries => _userItineraries;
  bool get isInitialized => _isInitialized;
  List<String> get availableInterests => AppConstants.availableInterests;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadUserInterests();
    _isInitialized = true;
    notifyListeners();
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
      print('Error loading user interests: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap({...doc.data()!, 'uid': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).update(profile.toMap());
      await loadUserInterests(); 
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Stream<List<UserProfile>> getPotentialTravelBuddies(
    String userId,
    List<String> interests,
  ) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('users');
      query = query.where(FieldPath.documentId, isNotEqualTo: userId);
      if (interests.isNotEmpty) {
        query = query.where('interests', arrayContainsAny: interests);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return UserProfile.fromMap({
            ...doc.data(),
            'uid': doc.id,
          });
        }).toList();
      });
    } catch (e) {
      print('Error in getPotentialTravelBuddies: $e');
      return Stream.value([]);
    }
  }

  Future<String> createNewItinerary(Itinerary itinerary) async {
    final doc = await _firestore.collection('itineraries').add(itinerary.toMap());
    await loadUserItineraries(itinerary.userId);
    return doc.id;
  }

  Future<void> loadUserItineraries(String userId) async {
    final snapshot = await _firestore
        .collection('itineraries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _userItineraries = snapshot.docs
        .map((doc) => Itinerary.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
    notifyListeners();
  }

  Future<void> addActivity(String itineraryId, int dayNumber, Activity activity) async {
    try {
      final itineraryDoc = _firestore.collection('itineraries').doc(itineraryId);
      
      final doc = await itineraryDoc.get();
      if (!doc.exists) throw Exception('Itinerary not found');
      
      final itinerary = Itinerary.fromMap({...doc.data()!, 'id': doc.id});
      
      final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
      if (dayIndex == -1) throw Exception('Day not found');
      
      final updatedDays = List<ItineraryDay>.from(itinerary.days);
      updatedDays[dayIndex] = ItineraryDay(
        dayNumber: dayNumber,
        activities: [...updatedDays[dayIndex].activities, activity],
      );

      await itineraryDoc.update({
        'days': updatedDays.map((day) => day.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await loadUserItineraries(itinerary.userId);
    } catch (e) {
      print('Error adding activity: $e');
      rethrow;
    }
  }

Future<void> reorderActivities(
  String itineraryId, 
  int dayNumber, 
  int oldIndex, 
  int newIndex
) async {
  try {
    final itineraryDoc = _firestore.collection('itineraries').doc(itineraryId);
    
    final doc = await itineraryDoc.get();
    if (!doc.exists) throw Exception('Itinerary not found');
    
    final itinerary = Itinerary.fromMap({...doc.data()!, 'id': doc.id});
    final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
    
    if (dayIndex == -1) throw Exception('Day not found');

    final updatedDays = List<ItineraryDay>.from(itinerary.days);
    final activities = List<Activity>.from(updatedDays[dayIndex].activities);
    
    final item = activities.removeAt(oldIndex);
    activities.insert(newIndex, item);

    updatedDays[dayIndex] = ItineraryDay(
      dayNumber: dayNumber,
      activities: activities,
    );

    await itineraryDoc.update({
      'days': updatedDays.map((day) => day.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await loadUserItineraries(itinerary.userId);
  } catch (e) {
    print('Error reordering activities: $e');
    rethrow;
  }
}

Future<void> deleteActivity(
  String itineraryId,
  int dayNumber,
  Activity activity,
) async {
  try {
    final itineraryDoc = _firestore.collection('itineraries').doc(itineraryId);
    
    final doc = await itineraryDoc.get();
    if (!doc.exists) throw Exception('Itinerary not found');
    
    final itinerary = Itinerary.fromMap({...doc.data()!, 'id': doc.id});
    
    final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) throw Exception('Day not found');

    final updatedDays = List<ItineraryDay>.from(itinerary.days);
    final updatedActivities = updatedDays[dayIndex].activities.where((a) => 
      a.name != activity.name || 
      a.startTime != activity.startTime || 
      a.endTime != activity.endTime
    ).toList();

    updatedDays[dayIndex] = ItineraryDay(
      dayNumber: dayNumber,
      activities: updatedActivities,
    );

    await itineraryDoc.update({
      'days': updatedDays.map((day) => day.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await loadUserItineraries(itinerary.userId);
  } catch (e) {
    print('Error deleting activity: $e');
    rethrow;
  }
}

Future<void> updateActivity(
  String itineraryId,
  int dayNumber,
  Activity oldActivity,
  Activity newActivity,
) async {
  try {
    final itineraryDoc = _firestore.collection('itineraries').doc(itineraryId);
    
    final doc = await itineraryDoc.get();
    if (!doc.exists) throw Exception('Itinerary not found');
    
    final itinerary = Itinerary.fromMap({...doc.data()!, 'id': doc.id});
    
    final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) throw Exception('Day not found');

    final updatedDays = List<ItineraryDay>.from(itinerary.days);
    final activities = List<Activity>.from(updatedDays[dayIndex].activities);
    
    final activityIndex = activities.indexWhere((a) => 
      a.name == oldActivity.name && 
      a.startTime == oldActivity.startTime && 
      a.endTime == oldActivity.endTime
    );
    
    if (activityIndex == -1) throw Exception('Activity not found');
    
    activities[activityIndex] = newActivity;

    updatedDays[dayIndex] = ItineraryDay(
      dayNumber: dayNumber,
      activities: activities,
    );

    await itineraryDoc.update({
      'days': updatedDays.map((day) => day.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await loadUserItineraries(itinerary.userId);
  } catch (e) {
    print('Error updating activity: $e');
    rethrow;
  }
}
Future<void> addPlaceToItinerary(
  String itineraryId, 
  int dayNumber, 
  Place place,
  DateTime startTime,
  DateTime endTime,
) async {
  try {
    final activity = Activity(
      name: place.name,
      placeId: place.id,
      startTime: startTime,
      endTime: endTime,
      notes: place.vicinity,
    );

    await addActivity(itineraryId, dayNumber, activity);
  } catch (e) {
    print('Error adding place to itinerary: $e');
    rethrow;
  }
}

  Stream<List<ChatMessage>> getChatMessages(String userId1, String userId2) {
    final chatId = _createChatId(userId1, userId2);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> sendMessage(ChatMessage message) async {
    final chatId = _createChatId(message.senderId, message.receiverId);

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [message.senderId, message.receiverId],
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp.toIso8601String(),
    });

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _updateUserChatList(message.senderId, message.receiverId, message);
    await _updateUserChatList(message.receiverId, message.senderId, message);
  }

  Stream<List<ChatPreview>> getUserChats(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists || userDoc.data()?['chatList'] == null) {
        return [];
      }

      final chatList = List<Map<String, dynamic>>.from(userDoc.data()!['chatList']);
      List<ChatPreview> previews = [];

      for (var chat in chatList) {
        final otherUserId = chat['userId'];
        final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
        
        if (otherUserDoc.exists) {
          previews.add(
            ChatPreview(
              otherUser: UserProfile.fromMap({...otherUserDoc.data()!, 'uid': otherUserDoc.id}),
              lastMessage: chat['lastMessage'],
              lastMessageTime: DateTime.parse(chat['lastMessageTime']),
              unreadCount: chat['unreadCount'] ?? 0,
            ),
          );
        }
      }

      return previews..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }

  Future<void> _updateUserChatList(
    String userId,
    String otherUserId,
    ChatMessage lastMessage,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'chatList': FieldValue.arrayUnion([
        {
          'userId': otherUserId,
          'lastMessage': lastMessage.content,
          'lastMessageTime': lastMessage.timestamp.toIso8601String(),
          'unreadCount': lastMessage.senderId == userId ? 0 : 1,
        }
      ]),
    });
  }

  String _createChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}

class ChatPreview {
  final UserProfile otherUser;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatPreview({
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}