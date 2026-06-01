import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/day_card_model.dart';
import '../models/mood.dart';
import '../theme/app_theme.dart';

class DayCardScreen extends StatefulWidget {
  final DayCardModel card;

  const DayCardScreen({super.key, required this.card});

  @override
  State<DayCardScreen> createState() => _DayCardScreenState();
}

class _DayCardScreenState extends State<DayCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.card.mood;
    final meta = mood.meta;
    final textColor = meta.textColor;

    return Scaffold(
      backgroundColor: meta.primaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(position: _slideUp, child: child),
        ),
        child: Stack(
          children: [
            // ── Background gradient ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: moodGradient(meta.primaryColor, meta.secondaryColor),
              ),
            ),

            // ── Subtle noise texture overlay ─────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _SubtleNoisePainter(textColor)),
            ),

            // ── Content ──────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Top bar: back button + date
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.arrow_back_ios,
                              color: textColor.withOpacity(0.6), size: 18),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d')
                              .format(widget.card.date)
                              .toUpperCase(),
                          style: AppTheme.labelSmallCaps.copyWith(
                            color: textColor.withOpacity(0.55),
                            letterSpacing: 2.5,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Celestial symbol ────────────────────────────
                            Text(
                              meta.symbol,
                              style: TextStyle(
                                fontSize: 32,
                                color: textColor.withOpacity(0.35),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Name ────────────────────────────────────────
                            Text(
                              widget.card.astro.transitMoonSign
                                  .toUpperCase()
                                  .split('')
                                  .join(' '),
                              style: AppTheme.labelSmallCaps.copyWith(
                                color: textColor.withOpacity(0.45),
                                letterSpacing: 4.0,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // ── Mood label ───────────────────────────────────
                            Text(
                              meta.label,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 42,
                                fontWeight: FontWeight.w300,
                                color: textColor,
                                letterSpacing: -1.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meta.description,
                              style: AppTheme.bodyText.copyWith(
                                color: textColor.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // ── Thin divider ─────────────────────────────────
                            Divider(
                              color: textColor.withOpacity(0.2),
                              thickness: 0.5,
                            ),
                            const SizedBox(height: 32),

                            // ── Quote ────────────────────────────────────────
                            _QuoteBlock(
                              text: widget.card.rephrasedQuote,
                              textColor: textColor,
                            ),

                            const SizedBox(height: 40),

                            // ── Thin divider ─────────────────────────────────
                            Divider(
                              color: textColor.withOpacity(0.2),
                              thickness: 0.5,
                            ),
                            const SizedBox(height: 24),

                            // ── Vedic snapshot row ────────────────────────────
                            _AstroRow(card: widget.card, textColor: textColor),

                            const SizedBox(height: 28),

                            // ── Short guidance ───────────────────────────────
                            _GuidanceBlock(
                              text: widget.card.shortGuidance,
                              textColor: textColor,
                            ),

                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quote Block ──────────────────────────────────────────────────────────────

class _QuoteBlock extends StatelessWidget {
  final String text;
  final Color textColor;

  const _QuoteBlock({required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Opening mark
        Text(
          '\u201C',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 72,
            fontWeight: FontWeight.w300,
            color: textColor.withOpacity(0.2),
            height: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 27,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: textColor,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Astro Row ────────────────────────────────────────────────────────────────

class _AstroRow extends StatelessWidget {
  final DayCardModel card;
  final Color textColor;

  const _AstroRow({required this.card, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: [
        _Chip(
          label: 'Moon  ${card.astro.transitMoonSign}',
          textColor: textColor,
        ),
        _Chip(
          label: card.astro.tithiName,
          textColor: textColor,
        ),
        _Chip(
          label: '${card.astro.dashaLord} Dasha',
          textColor: textColor,
        ),
        _Chip(
          label: card.astro.transitMoonNakshatra,
          textColor: textColor,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color textColor;

  const _Chip({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(20),
        color: textColor.withOpacity(0.08),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.labelSmallCaps.copyWith(
          color: textColor.withOpacity(0.65),
          fontSize: 9,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

// ─── Guidance Block ───────────────────────────────────────────────────────────

class _GuidanceBlock extends StatelessWidget {
  final String text;
  final Color textColor;

  const _GuidanceBlock({required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(16),
        color: textColor.withOpacity(0.06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦',
            style: TextStyle(
              color: textColor.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyText.copyWith(
                color: textColor.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subtle Noise Texture Painter ────────────────────────────────────────────

class _SubtleNoisePainter extends CustomPainter {
  final Color color;
  _SubtleNoisePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.03)
      ..strokeWidth = 0.5;

    // Draw very faint horizontal grain lines for texture
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y + (y % 11 < 6 ? 0.5 : 0)),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
