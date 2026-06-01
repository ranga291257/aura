import 'package:aura/models/mood.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mood extension exposes display metadata', () {
    expect(Mood.confident.label, 'Confident');
    expect(Mood.confident.meta.symbol, '☀');
  });
}
