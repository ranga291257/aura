import 'mood.dart';

class AstroSnapshot {
  final String transitMoonSign;
  final String transitMoonNakshatra;
  final String natalMoonSign;
  final String natalMoonNakshatra;
  final String dashaLord;
  final String antardasha;
  final String sunSign;
  final double moonDegree;
  final int moonPhase;
  final String tithiName;
  final String moonPhaseLabel;

  const AstroSnapshot({
    required this.transitMoonSign,
    required this.transitMoonNakshatra,
    required this.natalMoonSign,
    required this.natalMoonNakshatra,
    required this.dashaLord,
    required this.antardasha,
    required this.sunSign,
    required this.moonDegree,
    required this.moonPhase,
    required this.tithiName,
    required this.moonPhaseLabel,
  });
}

class DayCardModel {
  final DateTime date;
  final Mood mood;
  final String originalQuote;
  final String rephrasedQuote;
  final String quoteCategory;
  final AstroSnapshot astro;
  final String shortGuidance;

  const DayCardModel({
    required this.date,
    required this.mood,
    required this.originalQuote,
    required this.rephrasedQuote,
    required this.quoteCategory,
    required this.astro,
    required this.shortGuidance,
  });
}
