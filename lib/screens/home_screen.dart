import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/day_card_model.dart';
import '../models/mood.dart';
import '../models/user_profile.dart';
import '../services/day_card_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'day_card_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  DayCardModel? _todayCard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndBuild();
  }

  Future<void> _loadAndBuild() async {
    final profile = await StorageService.loadProfile();
    if (!mounted) return;

    if (profile == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final card = DayCardService.build(profile);

    setState(() {
      _profile = profile;
      _todayCard = card;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.cream,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.deepInk,
            strokeWidth: 1,
          ),
        ),
      );
    }

    final card = _todayCard;
    final profile = _profile;
    if (card == null || profile == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(
          'AURA',
          style: AppTheme.labelSmallCaps.copyWith(
            letterSpacing: 6,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _greeting(profile.firstName),
                  style: AppTheme.bodyText.copyWith(color: AppTheme.warmGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.deepInk,
                  ),
                ),
                const SizedBox(height: 28),
                _DayCardTile(card: card),
                const SizedBox(height: 24),
                _AstroStrip(card: card),
                const SizedBox(height: 24),
                _NatalStrip(card: card),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(String firstName) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $firstName';
    if (hour < 17) return 'Good afternoon, $firstName';
    return 'Good evening, $firstName';
  }
}

class _DayCardTile extends StatelessWidget {
  final DayCardModel card;
  const _DayCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final meta = card.mood.meta;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DayCardScreen(card: card)),
      ),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          gradient: moodGradient(meta.primaryColor, meta.secondaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meta.symbol,
                    style: TextStyle(
                      fontSize: 22,
                      color: meta.textColor.withOpacity(0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: meta.textColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meta.label.toUpperCase(),
                      style: AppTheme.labelSmallCaps.copyWith(
                        color: meta.textColor.withOpacity(0.7),
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _truncate(card.rephrasedQuote, 90),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 17,
                  fontStyle: FontStyle.italic,
                  color: meta.textColor,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'OPEN YOUR DAY',
                    style: AppTheme.labelSmallCaps.copyWith(
                      color: meta.textColor.withOpacity(0.55),
                      fontSize: 8,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 10,
                    color: meta.textColor.withOpacity(0.55),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max).trimRight()}…';
  }
}

class _AstroStrip extends StatelessWidget {
  final DayCardModel card;
  const _AstroStrip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TODAY'S SKY",
          style: AppTheme.labelSmallCaps.copyWith(
            color: AppTheme.warmGrey,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoCell(label: 'MOON', value: card.astro.transitMoonSign),
            _InfoCell(
              label: 'NAKSHATRA',
              value: card.astro.transitMoonNakshatra,
            ),
            _InfoCell(label: 'SUN', value: card.astro.sunSign),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _InfoCell(label: 'TITHI', value: card.astro.tithiName),
            _InfoCell(label: 'PHASE', value: card.astro.moonPhaseLabel),
            _InfoCell(label: 'DASHA', value: card.astro.dashaLord),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _InfoCell(label: 'ANTARDASHA', value: card.astro.antardasha),
          ],
        ),
      ],
    );
  }
}

class _NatalStrip extends StatelessWidget {
  final DayCardModel card;
  const _NatalStrip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR CHART',
          style: AppTheme.labelSmallCaps.copyWith(
            color: AppTheme.warmGrey,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoCell(label: 'NATAL MOON', value: card.astro.natalMoonSign),
            _InfoCell(
              label: 'NATAL NAKSHATRA',
              value: card.astro.natalMoonNakshatra,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          border: Border.all(color: AppTheme.lightDivider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.labelSmallCaps.copyWith(
                color: AppTheme.warmGrey,
                fontSize: 7.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                color: AppTheme.deepInk,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
