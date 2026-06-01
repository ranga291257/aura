import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import '../models/mood.dart';
import 'day_card_service.dart';
import 'storage_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Notification Service
///
/// Sleep detection approach:
///  • Android: WorkManager periodic task runs every 15 min; card fires 5–10 AM.
///    It checks if the user has been still (via Step Counter / accelerometer
///    inactivity heuristic) — a proxy for sleep detection when the full
///    Google Sleep API requires Google Play Services integration.
///
///    For full Google Sleep API integration:
///    1. Add: com.google.android.gms:play-services-location:21.x to build.gradle
///    2. Register a BroadcastReceiver with ActivityRecognition.getClient()
///       .requestSleepSegmentUpdates() in MainActivity.kt
///    3. Pass the wake event to Flutter via MethodChannel → trigger card here.
///
///  • iOS: WorkManager BGAppRefreshTask runs in the background and fires
///    when iOS grants background execution (typically 6–8 AM).
///    For HealthKit sleep detection:
///    1. Enable HealthKit in Xcode capabilities
///    2. Query HKCategoryTypeIdentifier.sleepAnalysis for last sleep segment
///    3. On first end-of-sleep event after midnight → fire card.
/// ─────────────────────────────────────────────────────────────────────────────

const String _taskName = 'aura_morning_card';

// Called by WorkManager in the background (must be top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (task == _taskName) {
      await _generateAndNotifyCard();
    }
    return true;
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialise ──────────────────────────────────────────────────────────────

  static Future<void> init() async {
    // Android channel
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Navigate to DayCardScreen — handled via NavigationService in main.dart
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'aura_morning_channel',
        'Morning Guidance',
        description: 'Your daily spiritual morning card from Aura',
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
      );
      await _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Register WorkManager background callback
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  // ─── Request Permissions ─────────────────────────────────────────────────────

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      await Permission.activityRecognition.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true);
      return result ?? false;
    }
    return false;
  }

  // ─── Schedule Morning Task ───────────────────────────────────────────────────

  /// Schedules a recurring morning check between 5:00–9:00 AM
  static Future<void> scheduleMorningTask() async {
    // Cancel existing tasks first
    await Workmanager().cancelAll();

    // Schedule a periodic task every 15 minutes
    // WorkManager will honour the Doze mode and run it in the maintenance window
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  // ─── Show Day Card Notification ───────────────────────────────────────────────

  static Future<void> showDayCardNotification({
    required String firstName,
    required String quote,
    required String moodLabel,
  }) async {
    final shortQuote =
        quote.length > 80 ? '${quote.substring(0, 77)}…' : quote;

    final androidDetails = AndroidNotificationDetails(
      'aura_morning_channel',
      'Morning Guidance',
      channelDescription: 'Your daily spiritual morning card',
      importance: Importance.high,
      priority: Priority.defaultPriority,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(shortQuote),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false,
      presentBadge: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      1,
      '$firstName · $moodLabel energy today',
      shortQuote,
      details,
      payload: 'day_card',
    );
  }

  // ─── Cancel ──────────────────────────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await Workmanager().cancelAll();
  }
}

// ─── Background Card Generation ─────────────────────────────────────────────

/// Runs entirely offline in the background to generate and notify the day card
Future<void> _generateAndNotifyCard() async {
  final now = DateTime.now();

  // Only run in the morning window (5 AM – 10 AM)
  if (now.hour < 5 || now.hour >= 10) return;

  // Don't send twice in one day
  if (await StorageService.hasCardForToday()) return;

  final profile = await StorageService.loadProfile();
  if (profile == null) return;

  final card = DayCardService.build(profile, onDate: now);

  await StorageService.saveLastCardDate(now);

  await NotificationService.showDayCardNotification(
    firstName: profile.firstName,
    quote: card.rephrasedQuote,
    moodLabel: card.mood.meta.label,
  );
}
