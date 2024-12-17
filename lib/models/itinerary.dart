class Itinerary {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryDay> days;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Itinerary({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.days = const [],
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      destination: map['destination'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      days: (map['days'] as List?)?.map((day) => ItineraryDay.fromMap(day)).toList() ?? [],
      isPublic: map['isPublic'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'days': days.map((day) => day.toMap()).toList(),
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ItineraryDay {
  final int dayNumber;
  final List<Activity> activities;

  ItineraryDay({
    required this.dayNumber,
    this.activities = const [],
  });

  factory ItineraryDay.fromMap(Map<String, dynamic> map) {
    return ItineraryDay(
      dayNumber: map['dayNumber'] ?? 0,
      activities: (map['activities'] as List?)
          ?.map((activity) => Activity.fromMap(activity))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'activities': activities.map((activity) => activity.toMap()).toList(),
    };
  }
}

class Activity {
  final String name;
  final String? placeId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  Activity({
    required this.name,
    this.placeId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'] ?? '',
      placeId: map['placeId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'placeId': placeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
    };
  }
}