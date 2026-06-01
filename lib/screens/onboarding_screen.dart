import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/birth_locations.dart';
import '../models/user_profile.dart';
import '../services/birth_timezone_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  final _nameCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCountryCode;
  BirthLocationEntry? _selectedLocation;
  String _citySearch = '';

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_step == 0 && _nameCtrl.text.trim().isEmpty) return;
    if (_step == 1 && (_selectedDate == null || _selectedTime == null)) return;
    if (_step == 2 && _selectedLocation == null) return;

    if (_step < 2) {
      await _fadeCtrl.reverse();
      setState(() => _step++);
      _fadeCtrl.forward();
    } else {
      _saveAndContinue();
    }
  }

  Future<void> _saveAndContinue() async {
    final loc = _selectedLocation!;
    final birthTzOffset = BirthTimezoneService.offsetMinutesAt(
      latitude: loc.latitude,
      longitude: loc.longitude,
      year: _selectedDate!.year,
      month: _selectedDate!.month,
      day: _selectedDate!.day,
      hour: _selectedTime!.hour,
      minute: _selectedTime!.minute,
    );

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      dateOfBirth: _selectedDate!,
      birthHour: _selectedTime!.hour,
      birthMinute: _selectedTime!.minute,
      birthCity: loc.displayLabel,
      birthLatitude: loc.latitude,
      birthLongitude: loc.longitude,
      birthTimezoneOffsetMinutes: birthTzOffset,
    );

    await StorageService.saveProfile(profile);
    await StorageService.setOnboarded();
    await NotificationService.requestPermissions();
    await NotificationService.scheduleMorningTask();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Row(
                  children: List.generate(3, (i) => _ProgressDot(
                    active: i <= _step,
                    current: i == _step,
                  )),
                ),
                const SizedBox(height: 48),
                Expanded(child: _buildStep()),
                const SizedBox(height: 32),
                _ContinueButton(
                  label: _step == 2 ? 'BEGIN' : 'CONTINUE',
                  onTap: _nextStep,
                  enabled: _canContinue(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_step == 0) return _nameCtrl.text.trim().isNotEmpty;
    if (_step == 1) return _selectedDate != null && _selectedTime != null;
    return _selectedLocation != null;
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepName(controller: _nameCtrl, onChanged: () => setState(() {}));
      case 1:
        return _StepBirth(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateSelected: (d) => setState(() => _selectedDate = d),
          onTimeSelected: (t) => setState(() => _selectedTime = t),
        );
      case 2:
        return _StepBirthPlace(
          countryCode: _selectedCountryCode,
          selectedLocation: _selectedLocation,
          citySearch: _citySearch,
          onCountryChanged: (code) => setState(() {
            _selectedCountryCode = code;
            _selectedLocation = null;
            _citySearch = '';
          }),
          onCitySearchChanged: (v) => setState(() => _citySearch = v),
          onLocationSelected: (loc) => setState(() {
            _selectedLocation = loc;
            _citySearch = loc.city;
          }),
          onClear: () => setState(() {
            _selectedLocation = null;
            _citySearch = '';
          }),
        );
      default:
        return const SizedBox();
    }
  }
}

class _StepName extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _StepName({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is your\nfull name?',
            style: GoogleFonts.cormorantGaramond(
                fontSize: 38, fontWeight: FontWeight.w300,
                color: AppTheme.deepInk, height: 1.2)),
        const SizedBox(height: 10),
        Text('Used to personalize your daily Vedic guidance.',
            style: AppTheme.bodyText.copyWith(
                color: AppTheme.warmGrey, fontSize: 14)),
        const SizedBox(height: 48),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.cormorantGaramond(
              fontSize: 24, color: AppTheme.deepInk),
          decoration: const InputDecoration(
            labelText: 'Full name',
            hintText: 'e.g. Priya Sharma',
          ),
        ),
      ],
    );
  }
}

class _StepBirth extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const _StepBirth({
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When were\nyou born?',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 38, fontWeight: FontWeight.w300,
                  color: AppTheme.deepInk, height: 1.2)),
          const SizedBox(height: 10),
          Text('Birth date and time are used for your natal chart and dasha.',
              style: AppTheme.bodyText.copyWith(
                  color: AppTheme.warmGrey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'Your birth year stays in this device\'s secure storage only.',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.warmGrey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),
          _PickerTile(
            label: 'DATE OF BIRTH',
            value: selectedDate != null
                ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                : null,
            placeholder: 'Select your birth date',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.deepInk,
                      surface: AppTheme.cream,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) onDateSelected(d);
            },
          ),
          const SizedBox(height: 16),
          _PickerTile(
            label: 'TIME OF BIRTH',
            value: selectedTime?.format(context),
            placeholder: 'Select birth time (approx. is fine)',
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.deepInk,
                      surface: AppTheme.cream,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (t != null) onTimeSelected(t);
            },
          ),
          const SizedBox(height: 20),
          Text('APPROXIMATE TIME',
              style: AppTheme.labelSmallCaps.copyWith(
                  color: AppTheme.warmGrey, fontSize: 9)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ApproxTimeChip(
                label: 'Early AM (~6)',
                selected: selectedTime?.hour == 6 && selectedTime?.minute == 0,
                onTap: () => onTimeSelected(const TimeOfDay(hour: 6, minute: 0)),
              ),
              _ApproxTimeChip(
                label: 'Morning (~9)',
                selected: selectedTime?.hour == 9 && selectedTime?.minute == 0,
                onTap: () => onTimeSelected(const TimeOfDay(hour: 9, minute: 0)),
              ),
              _ApproxTimeChip(
                label: 'Afternoon (~3)',
                selected: selectedTime?.hour == 15 && selectedTime?.minute == 0,
                onTap: () => onTimeSelected(const TimeOfDay(hour: 15, minute: 0)),
              ),
              _ApproxTimeChip(
                label: 'Evening (~6)',
                selected: selectedTime?.hour == 18 && selectedTime?.minute == 0,
                onTap: () => onTimeSelected(const TimeOfDay(hour: 18, minute: 0)),
              ),
              _ApproxTimeChip(
                label: 'Noon / unknown (~12)',
                selected: selectedTime?.hour == 12 && selectedTime?.minute == 0,
                onTap: () => onTimeSelected(const TimeOfDay(hour: 12, minute: 0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApproxTimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ApproxTimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.deepInk.withOpacity(0.12),
      checkmarkColor: AppTheme.deepInk,
      labelStyle: AppTheme.bodyText.copyWith(
        fontSize: 12,
        color: selected ? AppTheme.deepInk : AppTheme.warmGrey,
      ),
      side: BorderSide(
        color: selected ? AppTheme.deepInk : AppTheme.lightDivider,
      ),
    );
  }
}

class _StepBirthPlace extends StatelessWidget {
  final String? countryCode;
  final BirthLocationEntry? selectedLocation;
  final String citySearch;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCitySearchChanged;
  final ValueChanged<BirthLocationEntry> onLocationSelected;
  final VoidCallback onClear;

  const _StepBirthPlace({
    required this.countryCode,
    required this.selectedLocation,
    required this.citySearch,
    required this.onCountryChanged,
    required this.onCitySearchChanged,
    required this.onLocationSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cities = countryCode == null
        ? <BirthLocationEntry>[]
        : BirthLocations.searchInCountry(
            countryCode: countryCode!,
            query: citySearch,
          );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where were\nyou born?',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 38, fontWeight: FontWeight.w300,
                  color: AppTheme.deepInk, height: 1.2)),
          const SizedBox(height: 10),
          Text(
            'Choose country and nearest city. That gives latitude, longitude, '
            'and timezone for your chart — country alone is not enough.',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.warmGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          if (selectedLocation != null)
            _SelectedPlaceTile(
              label: selectedLocation!.displayLabel,
              onClear: onClear,
            )
          else ...[
            DropdownButtonFormField<String>(
              value: countryCode,
              decoration: const InputDecoration(labelText: 'Country'),
              hint: const Text('Select country'),
              items: BirthLocations.countryCodes
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(BirthLocations.countryNames[code]!),
                      ))
                  .toList(),
              onChanged: (code) {
                if (code != null) onCountryChanged(code);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: countryCode != null,
              onChanged: onCitySearchChanged,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: AppTheme.deepInk,
              ),
              decoration: InputDecoration(
                labelText: 'City',
                hintText: countryCode == null
                    ? 'Select country first'
                    : 'Type or pick your birth city',
              ),
            ),
            if (countryCode != null && cities.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...cities.map((loc) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      loc.city,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        color: AppTheme.deepInk,
                      ),
                    ),
                    onTap: () => onLocationSelected(loc),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool active;
  final bool current;
  const _ProgressDot({required this.active, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: current ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppTheme.deepInk : AppTheme.lightDivider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border.all(color: AppTheme.lightDivider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTheme.labelSmallCaps.copyWith(
                    color: AppTheme.warmGrey, fontSize: 9)),
            const SizedBox(height: 4),
            Text(
              value ?? placeholder,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: value != null
                    ? AppTheme.deepInk
                    : AppTheme.warmGrey.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlaceTile extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _SelectedPlaceTile({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.deepInk.withOpacity(0.05),
        border: Border.all(color: AppTheme.deepInk.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 18, color: AppTheme.deepInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 18, color: AppTheme.deepInk)),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppTheme.warmGrey),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ContinueButton({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        child: Text(label),
      ),
    );
  }
}
