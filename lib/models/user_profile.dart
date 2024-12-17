// lib/models/user_profile.dart
class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? bio;
  final List<String> interests;
  final List<String> languages;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.bio,
    this.interests = const [],
    this.languages = const [],
    this.preferences,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      interests: List<String>.from(map['interests'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      preferences: map['preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'interests': interests,
      'languages': languages,
      'preferences': preferences,
    };
  }
}