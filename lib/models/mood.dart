import 'package:flutter/material.dart';

enum Mood {
  confident,
  lowSad,
  stressed,
  unmotivated,
  anxious,
  confused,
  angry,
  hopeful,
  discouraged,
  determined,
}

class MoodMeta {
  final String label;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final String symbol; // Unicode celestial symbol
  final String planetaryEnergy;

  const MoodMeta({
    required this.label,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.symbol,
    required this.planetaryEnergy,
  });
}

const Map<Mood, MoodMeta> moodMetaMap = {
  Mood.confident: MoodMeta(
    label: 'Confident',
    description: 'A day of self-trust and clear direction',
    primaryColor: Color(0xFFBF9B30),
    secondaryColor: Color(0xFF8B6914),
    textColor: Color(0xFFF7EDD4),
    symbol: '☀',
    planetaryEnergy: 'Solar energy',
  ),
  Mood.lowSad: MoodMeta(
    label: 'Gentle',
    description: 'A day for softness and inner care',
    primaryColor: Color(0xFF5A7A9E),
    secondaryColor: Color(0xFF3A5A7E),
    textColor: Color(0xFFE8F0F8),
    symbol: '☽',
    planetaryEnergy: 'Lunar energy',
  ),
  Mood.stressed: MoodMeta(
    label: 'Steady',
    description: 'A day to breathe and simplify',
    primaryColor: Color(0xFFA36B6B),
    secondaryColor: Color(0xFF7A4A4A),
    textColor: Color(0xFFF7EDEC),
    symbol: '♂',
    planetaryEnergy: 'Mars energy',
  ),
  Mood.unmotivated: MoodMeta(
    label: 'Flowing',
    description: 'A day to move gently forward',
    primaryColor: Color(0xFF5E8C68),
    secondaryColor: Color(0xFF3D6B47),
    textColor: Color(0xFFEDF5EE),
    symbol: '♃',
    planetaryEnergy: 'Jupiter energy',
  ),
  Mood.anxious: MoodMeta(
    label: 'Present',
    description: 'A day to return to the now',
    primaryColor: Color(0xFF7B6BAE),
    secondaryColor: Color(0xFF5A4A8C),
    textColor: Color(0xFFF0EDF8),
    symbol: '♀',
    planetaryEnergy: 'Venus energy',
  ),
  Mood.confused: MoodMeta(
    label: 'Seeking',
    description: 'A day when the path reveals itself in motion',
    primaryColor: Color(0xFF3D7A8C),
    secondaryColor: Color(0xFF295A6B),
    textColor: Color(0xFFEDF4F7),
    symbol: '☿',
    planetaryEnergy: 'Mercury energy',
  ),
  Mood.angry: MoodMeta(
    label: 'Channelled',
    description: 'A day to turn intensity into intention',
    primaryColor: Color(0xFFA0593A),
    secondaryColor: Color(0xFF7A3B22),
    textColor: Color(0xFFF7EDE8),
    symbol: '♂',
    planetaryEnergy: 'Mars fire',
  ),
  Mood.hopeful: MoodMeta(
    label: 'Rising',
    description: 'A day of open possibility',
    primaryColor: Color(0xFFB87A4A),
    secondaryColor: Color(0xFF8C5A2E),
    textColor: Color(0xFFF7F0E8),
    symbol: '♃',
    planetaryEnergy: 'Jupiter light',
  ),
  Mood.discouraged: MoodMeta(
    label: 'Renewing',
    description: 'A day when the seed grows underground',
    primaryColor: Color(0xFF7A6B9E),
    secondaryColor: Color(0xFF5A4A7A),
    textColor: Color(0xFFF0EDF8),
    symbol: '♄',
    planetaryEnergy: 'Saturn depth',
  ),
  Mood.determined: MoodMeta(
    label: 'Focused',
    description: 'A day for deliberate, powerful action',
    primaryColor: Color(0xFF2D4A7A),
    secondaryColor: Color(0xFF1A2E5A),
    textColor: Color(0xFFE8EEF7),
    symbol: '♄',
    planetaryEnergy: 'Saturn will',
  ),
};

extension MoodExtension on Mood {
  MoodMeta get meta => moodMetaMap[this]!;
  String get label => meta.label;
  Color get primaryColor => meta.primaryColor;
  Color get secondaryColor => meta.secondaryColor;
  Color get textColor => meta.textColor;
  String get symbol => meta.symbol;
}
