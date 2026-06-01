class UserProfile {
  final String name;
  final String firstName;
  final DateTime dateOfBirth;
  final int birthHour; // 0-23
  final int birthMinute; // 0-59
  final String birthCity;
  final double birthLatitude;
  final double birthLongitude;
  final int birthTimezoneOffsetMinutes;

  UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.birthHour,
    required this.birthMinute,
    required this.birthCity,
    required this.birthLatitude,
    required this.birthLongitude,
    required this.birthTimezoneOffsetMinutes,
  }) : firstName = name.trim().split(' ').first;

  int get birthYear => dateOfBirth.year;
  int get birthMonth => dateOfBirth.month;
  int get birthDay => dateOfBirth.day;

  /// Profile JSON for SharedPreferences — birth year is intentionally omitted.
  Map<String, dynamic> toPrefsJson() => {
        'name': name,
        'birthMonth': birthMonth,
        'birthDay': birthDay,
        'birthHour': birthHour,
        'birthMinute': birthMinute,
        'birthCity': birthCity,
        'birthLat': birthLatitude,
        'birthLng': birthLongitude,
        'birthTzOffset': birthTimezoneOffsetMinutes,
      };

  factory UserProfile.fromPrefsJson(
    Map<String, dynamic> json, {
    required int birthYear,
  }) =>
      UserProfile(
        name: json['name'] as String,
        dateOfBirth: DateTime(
          birthYear,
          json['birthMonth'] as int,
          json['birthDay'] as int,
        ),
        birthHour: json['birthHour'] as int,
        birthMinute: json['birthMinute'] as int,
        birthCity: json['birthCity'] as String,
        birthLatitude: (json['birthLat'] as num).toDouble(),
        birthLongitude: (json['birthLng'] as num).toDouble(),
        birthTimezoneOffsetMinutes: json['birthTzOffset'] as int,
      );
}
