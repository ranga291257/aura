/// Web stub — local notifications and WorkManager are not supported on web.
class NotificationService {
  static Future<void> init() async {}

  static Future<bool> requestPermissions() async => false;

  static Future<void> scheduleMorningTask() async {}

  static Future<void> showDayCardNotification({
    required String firstName,
    required String quote,
    required String moodLabel,
  }) async {}

  static Future<void> cancelAll() async {}
}
