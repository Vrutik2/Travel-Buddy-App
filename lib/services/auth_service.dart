import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  /// **Sign Up Method**
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);

      // Firebase Auth Sign-Up
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Update Display Name
      await _user!.updateDisplayName(name);
      await _user!.reload();

      _setErrorMessage(null);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
      return false; // Failure
    } finally {
      _setLoading(false);
    }
  }

  /// **Sign In Method**
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      // Firebase Auth Sign-In
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _setErrorMessage(null);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
      return false; // Failure
    } finally {
      _setLoading(false);
    }
  }

  /// **Sign Out Method**
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// **Loading State Handler**
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// **Error Message Handler**
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}