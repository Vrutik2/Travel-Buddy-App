import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppProvider with ChangeNotifier {
  List<Map<String, dynamic>> _popularDestinations = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String _error = '';

  final Map<String, double> _exchangeRates = {};
  String _selectedCurrency = 'USD';

  List<Map<String, dynamic>> _travelBuddies = [];
  List<String> _userInterests = [];

  List<Map<String, dynamic>> get popularDestinations => _popularDestinations;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, double> get exchangeRates => _exchangeRates;
  String get selectedCurrency => _selectedCurrency;
  List<Map<String, dynamic>> get travelBuddies => _travelBuddies;
  List<String> get userInterests => _userInterests;

  Future<void> initialize() async {
    await Future.wait([
      fetchPopularDestinations(),
      fetchExchangeRates(),
      fetchTravelBuddies(),
    ]);
  }

  Future<void> fetchPopularDestinations() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .orderBy('popularity', descending: true)
          .limit(10)
          .get();

      _popularDestinations = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Failed to fetch destinations';
      print('Error fetching destinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchDestinations(String query) async {
    _searchQuery = query;
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      _popularDestinations = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Search failed';
      print('Error searching destinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExchangeRates() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('YOUR_CURRENCY_API_ENDPOINT'),
        headers: {'apiKey': 'YOUR_API_KEY'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        data['rates'].forEach((key, value) {
          _exchangeRates[key] = double.parse(value.toString());
        });
        _error = '';
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      _error = 'Failed to fetch exchange rates';
      print('Error fetching exchange rates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  double convertCurrency(double amount, String fromCurrency, String toCurrency) {
    if (_exchangeRates.isEmpty) return amount;
    
    final double fromRate = _exchangeRates[fromCurrency] ?? 1;
    final double toRate = _exchangeRates[toCurrency] ?? 1;
    
    return (amount / fromRate) * toRate;
  }

  Future<void> fetchTravelBuddies() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('interests', arrayContainsAny: _userInterests)
          .limit(20)
          .get();

      _travelBuddies = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Failed to fetch travel buddies';
      print('Error fetching travel buddies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    _userInterests = interests;
    await fetchTravelBuddies();
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _chats = [];
  String _currentChatId = '';

  List<Map<String, dynamic>> get chats => _chats;
  String get currentChatId => _currentChatId;

  Future<void> fetchChats(String userId) async {
    try {
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

      notifyListeners();
    } catch (e) {
      print('Error fetching chats: $e');
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
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void setCurrentChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }
}