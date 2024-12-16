import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _error = '';
  bool _isLoading = false;

  User? get user => _user;
  String get error => _error;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Login failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Add user to Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Signup failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}