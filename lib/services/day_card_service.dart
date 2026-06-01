import '../models/day_card_model.dart';
import '../models/mood.dart';
import '../models/user_profile.dart';
import 'astrology_service.dart';
import 'mood_engine.dart';
import 'quote_service.dart';

/// Builds the daily card from profile + optional date (defaults to now).
class DayCardService {
  static DayCardModel build(UserProfile profile, {DateTime? onDate}) {
    final date = onDate ?? DateTime.now();
    final transit = AstrologyService.todayTransit(profile);
    final mood = MoodEngine.determineMood(transit);

    final dayQuote = QuoteService.getQuoteForDay(
      mood: mood,
      user: profile,
      date: date,
      moonSign: transit.transitMoonSign,
      moonNakshatra: transit.transitMoonNakshatra,
      dashaLord: transit.dashaLord,
    );

    return DayCardModel(
      date: date,
      mood: mood,
      originalQuote: dayQuote.original,
      rephrasedQuote: dayQuote.rephrased,
      quoteCategory: mood.label,
      astro: _astroFromTransit(transit),
      shortGuidance: MoodEngine.buildGuidance(transit),
    );
  }

  static AstroSnapshot _astroFromTransit(DailyTransit transit) {
    return AstroSnapshot(
      transitMoonSign: transit.transitMoonSign,
      transitMoonNakshatra: transit.transitMoonNakshatra,
      natalMoonSign: transit.natalMoonSign,
      natalMoonNakshatra: transit.natalMoonNakshatra,
      dashaLord: transit.dashaLord,
      antardasha: transit.antardasha,
      sunSign: transit.transitSunSign,
      moonDegree: transit.transitMoonDegree,
      moonPhase: transit.tithi,
      tithiName: transit.tithiName,
      moonPhaseLabel: transit.moonPhaseLabel,
    );
  }
}
