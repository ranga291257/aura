import 'package:aura/models/user_profile.dart';
import 'package:aura/services/birth_timezone_service.dart';
import 'package:aura/services/day_card_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await BirthTimezoneService.ensureInitialized();
  });

  test('build returns card with vedic fields populated', () {
    final profile = UserProfile(
      name: 'Test User',
      dateOfBirth: DateTime(1990, 6, 15),
      birthHour: 8,
      birthMinute: 30,
      birthCity: 'Mumbai, India',
      birthLatitude: 19.076,
      birthLongitude: 72.8777,
      birthTimezoneOffsetMinutes: 330,
    );

    final card = DayCardService.build(
      profile,
      onDate: DateTime(2026, 3, 15, 9),
    );

    expect(card.rephrasedQuote, isNotEmpty);
    expect(card.astro.transitMoonSign, isNotEmpty);
    expect(card.astro.dashaLord, isNotEmpty);
    expect(card.shortGuidance, contains('Moon'));
  });
}
