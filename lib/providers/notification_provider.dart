import 'dart:math';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _notificationsEnabled = true;
  bool _healthTipsEnabled = true;
  bool _monthlySummaryEnabled = true;

  TimeOfDay get reminderTime => _reminderTime;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get healthTipsEnabled => _healthTipsEnabled;
  bool get monthlySummaryEnabled => _monthlySummaryEnabled;

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'daily_reminder',
          channelName: 'Daily Reminder',
          channelDescription: 'Daily voice analysis reminder',
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'monthly_summary',
          channelName: 'Monthly Summary',
          channelDescription: 'Monthly health summary notification',
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'health_tips',
          channelName: 'Health Tips',
          channelDescription: 'Health tips and recommendations',
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  Future<void> updateSettings({
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
    bool? healthTipsEnabled,
    bool? monthlySummaryEnabled,
  }) async {
    if (reminderTime != null) _reminderTime = reminderTime;
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    if (healthTipsEnabled != null) _healthTipsEnabled = healthTipsEnabled;
    if (monthlySummaryEnabled != null) _monthlySummaryEnabled = monthlySummaryEnabled;

    if (_notificationsEnabled) {
      await scheduleDailyReminder();
      if (_monthlySummaryEnabled) await scheduleMonthlyReminder();
      if (_healthTipsEnabled) await scheduleHealthTip();
    } else {
      await cancelAllNotifications();
    }
    notifyListeners();
  }

  Future<void> scheduleDailyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'daily_reminder',
        title: 'Voice Analysis Reminder',
        body: 'Time for your daily voice recording!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> scheduleMonthlyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'monthly_summary',
        title: 'Monthly Health Summary',
        body: 'Your health analysis for the past month is ready!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        day: 1,
        hour: 9,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> scheduleHealthTip() async {
    final random = Random();
    final daysToAdd = random.nextInt(7) + 1;
    final now = DateTime.now().add(Duration(days: daysToAdd));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'health_tips',
        title: 'Health Tip',
        body: 'Did you know? Regular exercise can help reduce T2DM risk!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.hour,
        minute: now.minute,
        second: 0,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
