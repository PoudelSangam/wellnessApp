import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    Logger.info('Notification service initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('Notification tapped: ${response.payload}');
    // Handle notification tap
  }

  Future<void> requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Show Immediate Notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'wellness_channel',
      'Wellness Notifications',
      channelDescription: 'Notifications for wellness activities and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    Logger.info('Notification shown: $title');
  }

  // Schedule Daily Notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily wellness activity reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    Logger.info('Daily notification scheduled: $title at $hour:$minute');
  }

  // Cancel Notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    Logger.info('Notification cancelled: $id');
  }

  // Cancel All Notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    Logger.info('All notifications cancelled');
  }

  // Schedule Workout Reminder
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async {
    await scheduleDailyNotification(
      id: 1,
      title: '🏃 Time for Your Wellness Activity!',
      body: 'Don\'t forget to complete today\'s recommended activities',
      hour: hour,
      minute: minute,
    );
  }

  // Schedule Stress Check-in
  Future<void> scheduleStressCheckIn({
    required int hour,
    required int minute,
  }) async {
    await scheduleDailyNotification(
      id: 2,
      title: '😌 How are you feeling?',
      body: 'Take a moment to check in with yourself',
      hour: hour,
      minute: minute,
    );
  }

  // Show Encouragement Notification
  Future<void> showEncouragementNotification() async {
    await showNotification(
      id: 3,
      title: '💪 Great Progress!',
      body: 'You\'re doing amazing! Keep up the great work on your wellness journey.',
    );
  }
}
