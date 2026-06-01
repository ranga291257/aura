/// Offline birth places: country → city with coordinates for chart math.
class BirthLocationEntry {
  final String city;
  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;

  const BirthLocationEntry({
    required this.city,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
  });

  String get displayLabel => '$city, $countryName';
}

class BirthLocations {
  static const Map<String, String> countryNames = {
    'IN': 'India',
    'US': 'United States',
    'GB': 'United Kingdom',
    'AE': 'United Arab Emirates',
    'SG': 'Singapore',
    'AU': 'Australia',
    'CA': 'Canada',
    'FR': 'France',
    'DE': 'Germany',
    'JP': 'Japan',
    'CN': 'China',
    'PK': 'Pakistan',
    'BD': 'Bangladesh',
    'LK': 'Sri Lanka',
    'NP': 'Nepal',
  };

  static const List<BirthLocationEntry> all = [
    BirthLocationEntry(city: 'Mumbai', countryCode: 'IN', countryName: 'India', latitude: 19.0760, longitude: 72.8777),
    BirthLocationEntry(city: 'Delhi', countryCode: 'IN', countryName: 'India', latitude: 28.6139, longitude: 77.2090),
    BirthLocationEntry(city: 'Bangalore', countryCode: 'IN', countryName: 'India', latitude: 12.9716, longitude: 77.5946),
    BirthLocationEntry(city: 'Chennai', countryCode: 'IN', countryName: 'India', latitude: 13.0827, longitude: 80.2707),
    BirthLocationEntry(city: 'Kolkata', countryCode: 'IN', countryName: 'India', latitude: 22.5726, longitude: 88.3639),
    BirthLocationEntry(city: 'Hyderabad', countryCode: 'IN', countryName: 'India', latitude: 17.3850, longitude: 78.4867),
    BirthLocationEntry(city: 'Pune', countryCode: 'IN', countryName: 'India', latitude: 18.5204, longitude: 73.8567),
    BirthLocationEntry(city: 'Ahmedabad', countryCode: 'IN', countryName: 'India', latitude: 23.0225, longitude: 72.5714),
    BirthLocationEntry(city: 'Jaipur', countryCode: 'IN', countryName: 'India', latitude: 26.9124, longitude: 75.7873),
    BirthLocationEntry(city: 'New York', countryCode: 'US', countryName: 'United States', latitude: 40.7128, longitude: -74.0060),
    BirthLocationEntry(city: 'Los Angeles', countryCode: 'US', countryName: 'United States', latitude: 34.0522, longitude: -118.2437),
    BirthLocationEntry(city: 'Chicago', countryCode: 'US', countryName: 'United States', latitude: 41.8781, longitude: -87.6298),
    BirthLocationEntry(city: 'Houston', countryCode: 'US', countryName: 'United States', latitude: 29.7604, longitude: -95.3698),
    BirthLocationEntry(city: 'San Francisco', countryCode: 'US', countryName: 'United States', latitude: 37.7749, longitude: -122.4194),
    BirthLocationEntry(city: 'London', countryCode: 'GB', countryName: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
    BirthLocationEntry(city: 'Manchester', countryCode: 'GB', countryName: 'United Kingdom', latitude: 53.4808, longitude: -2.2426),
    BirthLocationEntry(city: 'Dubai', countryCode: 'AE', countryName: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708),
    BirthLocationEntry(city: 'Singapore', countryCode: 'SG', countryName: 'Singapore', latitude: 1.3521, longitude: 103.8198),
    BirthLocationEntry(city: 'Sydney', countryCode: 'AU', countryName: 'Australia', latitude: -33.8688, longitude: 151.2093),
    BirthLocationEntry(city: 'Melbourne', countryCode: 'AU', countryName: 'Australia', latitude: -37.8136, longitude: 144.9631),
    BirthLocationEntry(city: 'Toronto', countryCode: 'CA', countryName: 'Canada', latitude: 43.6532, longitude: -79.3832),
    BirthLocationEntry(city: 'Vancouver', countryCode: 'CA', countryName: 'Canada', latitude: 49.2827, longitude: -123.1207),
    BirthLocationEntry(city: 'Paris', countryCode: 'FR', countryName: 'France', latitude: 48.8566, longitude: 2.3522),
    BirthLocationEntry(city: 'Berlin', countryCode: 'DE', countryName: 'Germany', latitude: 52.5200, longitude: 13.4050),
    BirthLocationEntry(city: 'Tokyo', countryCode: 'JP', countryName: 'Japan', latitude: 35.6762, longitude: 139.6503),
    BirthLocationEntry(city: 'Beijing', countryCode: 'CN', countryName: 'China', latitude: 39.9042, longitude: 116.4074),
    BirthLocationEntry(city: 'Shanghai', countryCode: 'CN', countryName: 'China', latitude: 31.2304, longitude: 121.4737),
    BirthLocationEntry(city: 'Karachi', countryCode: 'PK', countryName: 'Pakistan', latitude: 24.8607, longitude: 67.0011),
    BirthLocationEntry(city: 'Lahore', countryCode: 'PK', countryName: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
    BirthLocationEntry(city: 'Islamabad', countryCode: 'PK', countryName: 'Pakistan', latitude: 33.6844, longitude: 73.0479),
    BirthLocationEntry(city: 'Dhaka', countryCode: 'BD', countryName: 'Bangladesh', latitude: 23.8103, longitude: 90.4125),
    BirthLocationEntry(city: 'Colombo', countryCode: 'LK', countryName: 'Sri Lanka', latitude: 6.9271, longitude: 79.8612),
    BirthLocationEntry(city: 'Kathmandu', countryCode: 'NP', countryName: 'Nepal', latitude: 27.7172, longitude: 85.3240),
  ];

  static final List<String> countryCodes = () {
    final codes = countryNames.keys.toList()
      ..sort((a, b) => countryNames[a]!.compareTo(countryNames[b]!));
    return codes;
  }();

  static List<BirthLocationEntry> citiesInCountry(String countryCode) =>
      all.where((e) => e.countryCode == countryCode).toList()
        ..sort((a, b) => a.city.compareTo(b.city));

  static List<BirthLocationEntry> searchInCountry({
    required String countryCode,
    required String query,
    int limit = 8,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return citiesInCountry(countryCode).take(limit).toList();
    return citiesInCountry(countryCode)
        .where((e) => e.city.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }
}
