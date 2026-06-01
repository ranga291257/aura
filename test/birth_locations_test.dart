import 'package:aura/data/birth_locations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('searchInCountry filters by city name', () {
    final results = BirthLocations.searchInCountry(
      countryCode: 'IN',
      query: 'chen',
    );
    expect(results, isNotEmpty);
    expect(results.first.city, 'Chennai');
  });

  test('citiesInCountry returns only that country', () {
    final us = BirthLocations.citiesInCountry('US');
    expect(us.every((e) => e.countryCode == 'US'), isTrue);
  });
}
