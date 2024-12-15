import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'interests': [],
          'travelPreferences': {},
        });

        await userCredential.user!.updateDisplayName(name);
        if (photoUrl != null) {
          await userCredential.user!.updatePhotoURL(photoUrl);
        }

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      if (_user == null) return false;

      if (name != null) {
        await _user!.updateDisplayName(name);
        await _firestore.collection('users').doc(_user!.uid).update({
          'name': name,
        });
      }

      if (photoUrl != null) {
        await _user!.updatePhotoURL(photoUrl);
        await _firestore.collection('users').doc(_user!.uid).update({
          'photoUrl': photoUrl,
        });
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _error = 'No user found with this email.';
        break;
      case 'wrong-password':
        _error = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        _error = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        _error = 'Invalid email address.';
        break;
      case 'weak-password':
        _error = 'The password provided is too weak.';
        break;
      default:
        _error = 'An error occurred. Please try again.';
    }
    notifyListeners();
  }
}