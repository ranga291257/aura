import 'package:aura/services/birth_timezone_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await BirthTimezoneService.ensureInitialized();
  });

  group('BirthTimezoneService.offsetMinutesAt', () {
    test('IST offset for Mumbai summer date', () {
      final offset = BirthTimezoneService.offsetMinutesAt(
        latitude: 19.076,
        longitude: 72.8777,
        year: 1990,
        month: 6,
        day: 15,
        hour: 8,
        minute: 30,
      );
      expect(offset, 330);
    });

    test('returns sensible offset for New York', () {
      final offset = BirthTimezoneService.offsetMinutesAt(
        latitude: 40.7128,
        longitude: -74.006,
        year: 1990,
        month: 1,
        day: 15,
        hour: 12,
        minute: 0,
      );
      expect(offset, lessThanOrEqualTo(-240));
      expect(offset, greaterThanOrEqualTo(-300));
    });
  });
}
