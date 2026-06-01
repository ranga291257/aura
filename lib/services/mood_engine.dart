import '../models/mood.dart';
import 'astrology_service.dart';

/// Mood Engine — Vedic astrology only
///
/// Scoring (100 pts):
///   1. Transit Moon sign        45%
///   2. Mahadasha lord           35%
///   3. Antardasha lord          15%
///   + waxing/waning Moon tweak
class MoodEngine {
  static Mood determineMood(DailyTransit transit) {
    final scores = <Mood, double>{
      for (final mood in Mood.values) mood: 0.0,
    };

    _applyMoonSign(scores, transit.transitMoonSign, 45.0);
    _applyDashaLord(scores, transit.dashaLord, 35.0);
    _applyDashaLord(scores, transit.antardasha, 15.0);

    if (transit.isWaxing) {
      scores[Mood.hopeful] = (scores[Mood.hopeful]! + 5.0);
      scores[Mood.determined] = (scores[Mood.determined]! + 3.0);
    } else {
      scores[Mood.confused] = (scores[Mood.confused]! + 3.0);
      scores[Mood.discouraged] = (scores[Mood.discouraged]! + 2.0);
    }

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static String buildGuidance(DailyTransit transit) {
    return 'Moon in ${transit.transitMoonSign} (${transit.transitMoonNakshatra}), '
        '${transit.dashaLord} Mahadasha · ${transit.antardasha} Antardasha — '
        '${transit.tithiName}, ${transit.moonPhaseLabel} Moon.';
  }

  static void _applyMoonSign(
      Map<Mood, double> scores, String moonSign, double weight) {
    final contributions = _moonSignMoods[moonSign] ?? {};
    contributions.forEach((mood, fraction) {
      scores[mood] = (scores[mood]! + weight * fraction);
    });
  }

  static const Map<String, Map<Mood, double>> _moonSignMoods = {
    'Aries': {
      Mood.confident: 0.35, Mood.determined: 0.30,
      Mood.angry: 0.20, Mood.stressed: 0.15,
    },
    'Taurus': {
      Mood.hopeful: 0.30, Mood.unmotivated: 0.25,
      Mood.determined: 0.25, Mood.lowSad: 0.20,
    },
    'Gemini': {
      Mood.anxious: 0.30, Mood.confused: 0.30,
      Mood.hopeful: 0.25, Mood.stressed: 0.15,
    },
    'Cancer': {
      Mood.lowSad: 0.35, Mood.anxious: 0.25,
      Mood.hopeful: 0.25, Mood.confused: 0.15,
    },
    'Leo': {
      Mood.confident: 0.40, Mood.hopeful: 0.30,
      Mood.determined: 0.20, Mood.angry: 0.10,
    },
    'Virgo': {
      Mood.stressed: 0.30, Mood.anxious: 0.25,
      Mood.determined: 0.25, Mood.confused: 0.20,
    },
    'Libra': {
      Mood.hopeful: 0.35, Mood.confused: 0.25,
      Mood.anxious: 0.25, Mood.unmotivated: 0.15,
    },
    'Scorpio': {
      Mood.determined: 0.30, Mood.angry: 0.25,
      Mood.lowSad: 0.25, Mood.discouraged: 0.20,
    },
    'Sagittarius': {
      Mood.hopeful: 0.40, Mood.confident: 0.30,
      Mood.determined: 0.20, Mood.unmotivated: 0.10,
    },
    'Capricorn': {
      Mood.determined: 0.40, Mood.stressed: 0.25,
      Mood.discouraged: 0.20, Mood.unmotivated: 0.15,
    },
    'Aquarius': {
      Mood.confused: 0.30, Mood.hopeful: 0.30,
      Mood.anxious: 0.25, Mood.confident: 0.15,
    },
    'Pisces': {
      Mood.lowSad: 0.30, Mood.confused: 0.25,
      Mood.anxious: 0.25, Mood.hopeful: 0.20,
    },
  };

  static void _applyDashaLord(
      Map<Mood, double> scores, String lord, double weight) {
    final contributions = _dashaLordMoods[lord] ?? {};
    contributions.forEach((mood, fraction) {
      scores[mood] = (scores[mood]! + weight * fraction);
    });
  }

  static const Map<String, Map<Mood, double>> _dashaLordMoods = {
    'Sun': {
      Mood.confident: 0.40, Mood.determined: 0.35, Mood.angry: 0.25,
    },
    'Moon': {
      Mood.lowSad: 0.30, Mood.anxious: 0.30,
      Mood.hopeful: 0.25, Mood.confused: 0.15,
    },
    'Mars': {
      Mood.determined: 0.35, Mood.angry: 0.35,
      Mood.confident: 0.20, Mood.stressed: 0.10,
    },
    'Rahu': {
      Mood.anxious: 0.30, Mood.confused: 0.30,
      Mood.hopeful: 0.25, Mood.stressed: 0.15,
    },
    'Jupiter': {
      Mood.hopeful: 0.40, Mood.confident: 0.35, Mood.determined: 0.25,
    },
    'Saturn': {
      Mood.discouraged: 0.30, Mood.determined: 0.30,
      Mood.stressed: 0.25, Mood.lowSad: 0.15,
    },
    'Mercury': {
      Mood.anxious: 0.30, Mood.confused: 0.25,
      Mood.stressed: 0.25, Mood.hopeful: 0.20,
    },
    'Ketu': {
      Mood.confused: 0.30, Mood.lowSad: 0.30,
      Mood.anxious: 0.25, Mood.discouraged: 0.15,
    },
    'Venus': {
      Mood.hopeful: 0.35, Mood.confident: 0.30,
      Mood.unmotivated: 0.20, Mood.lowSad: 0.15,
    },
  };
}
