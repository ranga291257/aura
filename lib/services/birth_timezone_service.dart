import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Resolves UTC offset (minutes east of UTC) for a birth moment at city coordinates.
class BirthTimezoneService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  /// Offset in minutes to subtract from UTC to get local civil time at birth
  /// (matches existing [UserProfile.birthTimezoneOffsetMinutes] convention).
  static int offsetMinutesAt({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) {
    if (!_initialized) {
      throw StateError('Call BirthTimezoneService.ensureInitialized() first');
    }

    final tzId = tzmap.latLngToTimezoneString(latitude, longitude);
    if (tzId.isEmpty) return 0;

    try {
      final location = tz.getLocation(tzId);
      final zoned = tz.TZDateTime(
        location,
        year,
        month,
        day,
        hour,
        minute,
      );
      return zoned.timeZoneOffset.inMinutes;
    } catch (_) {
      return 0;
    }
  }
}
