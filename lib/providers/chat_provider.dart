import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _chats = [];
  String _currentChatId = '';
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get chats => _chats;
  String get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      _chats = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Failed to fetch chats';
      print('Error fetching chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String message) async {
    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _error = '';
    } catch (e) {
      _error = 'Failed to send message';
      print('Error sending message: $e');
    } finally {
      notifyListeners();
    }
  }

  void setCurrentChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }
}