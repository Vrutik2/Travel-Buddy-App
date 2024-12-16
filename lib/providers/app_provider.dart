import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  List<String> _interests = [];

  List<String> get interests => _interests;

  Future<void> updateUserInterests(List<String> newInterests) async {
    _interests = newInterests;
    notifyListeners();
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}