import '../models/mood.dart';
import '../models/user_profile.dart';
import '../data/quotes.dart';

class QuoteService {
  static DayQuote getQuoteForDay({
    required Mood mood,
    required UserProfile user,
    required DateTime date,
    required String moonSign,
    required String moonNakshatra,
    required String dashaLord,
  }) {
    final quotes = quoteBank[mood]!;

    final seed = _dailySeed(user, date);
    final quoteIndex = seed % quotes.length;
    final transformIndex = (seed ~/ quotes.length) % _templates.length;

    final original = quotes[quoteIndex];
    final rephrased = _rephrase(
      original: original,
      templateIndex: transformIndex,
      firstName: user.firstName,
      moonSign: moonSign,
      moonNakshatra: moonNakshatra,
      dashaLord: dashaLord,
      mood: mood,
    );

    return DayQuote(
      original: original,
      rephrased: rephrased,
      mood: mood,
      quoteIndex: quoteIndex,
    );
  }

  static int _dailySeed(UserProfile user, DateTime date) {
    final dayOfYear = _dayOfYear(date);
    final dobSeed = user.birthDay + user.birthMonth * 31;
    return (dayOfYear + dobSeed + user.name.length * 7) % 100;
  }

  static int _dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  static String _rephrase({
    required String original,
    required int templateIndex,
    required String firstName,
    required String moonSign,
    required String moonNakshatra,
    required String dashaLord,
    required Mood mood,
  }) {
    final template = _templates[templateIndex % _templates.length];
    return template(
      original: original,
      firstName: firstName,
      moonSign: moonSign,
      moonNakshatra: moonNakshatra,
      dashaLord: dashaLord,
      mood: mood,
    );
  }

  static final List<QuoteTransformer> _templates = [
    (
        {required original, required firstName, required moonSign,
          required moonNakshatra, required dashaLord, required mood}) =>
        original,
    (
        {required original, required firstName, required moonSign,
          required moonNakshatra, required dashaLord, required mood}) =>
        '$firstName, today the universe offers this reminder:\n\n$original',
    (
        {required original, required firstName, required moonSign,
          required moonNakshatra, required dashaLord, required mood}) =>
        'With the Moon in $moonSign and $dashaLord guiding this period — '
        '${_lowercaseFirst(original)}',
    (
        {required original, required firstName, required moonSign,
          required moonNakshatra, required dashaLord, required mood}) =>
        _reflectiveReframe(original),
    (
        {required original, required firstName, required moonSign,
          required moonNakshatra, required dashaLord, required mood}) =>
        'Under today\'s $moonNakshatra nakshatra, carry this with you:\n\n$original',
  ];

  static String _reflectiveReframe(String quote) {
    if (quote.startsWith('You ')) {
      return 'What if ${_lowercaseFirst(quote)}?';
    }
    if (quote.contains('; ')) {
      final parts = quote.split('; ');
      if (parts.length == 2) {
        return '${parts[1].trim().replaceAll('.', '')} — '
            '${_lowercaseFirst(parts[0])}.';
      }
    }
    if (quote.contains(' is ') && !quote.contains(',')) {
      return quote.replaceFirst(' is ', ' becomes ');
    }
    return 'Take a breath and hold this:\n\n$quote';
  }

  static String _lowercaseFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  // ignore: unused_element
  static String _buildSlmPrompt({
    required String originalQuote,
    required String firstName,
    required String moonSign,
    required String moonNakshatra,
    required String dashaLord,
    required String moodLabel,
  }) {
    return '''You are a gentle spiritual guide writing a personal morning message.

Context:
- Person's name: $firstName
- Today's Moon sign: $moonSign
- Today's nakshatra: $moonNakshatra
- Current dasha (life period): $dashaLord
- Today's emotional energy: $moodLabel

Original quote to lightly rephrase (keep the meaning, vary the wording slightly):
"$originalQuote"

Write ONE short, warm, personal rephrasing of this quote. 
Keep it under 40 words. Do not add generic phrases like "Remember" or "As you begin your day".
Make it feel like a quiet whisper, not a motivational poster.''';
  }
}

typedef QuoteTransformer = String Function({
  required String original,
  required String firstName,
  required String moonSign,
  required String moonNakshatra,
  required String dashaLord,
  required Mood mood,
});

class DayQuote {
  final String original;
  final String rephrased;
  final Mood mood;
  final int quoteIndex;

  const DayQuote({
    required this.original,
    required this.rephrased,
    required this.mood,
    required this.quoteIndex,
  });
}
