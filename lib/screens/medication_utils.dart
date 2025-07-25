import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationUtils {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final DeviceCalendarPlugin calendarPlugin = DeviceCalendarPlugin();

  /// Initialize local notifications and timezone data
  static Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initSettings);

    // Initialize timezone data
    tz.initializeTimeZones();
  }

  /// Schedule a daily notification at a specific time
  static Future<void> scheduleNotification(String name, TimeOfDay time) async {
    final androidDetails = AndroidNotificationDetails(
      'meds_channel_id',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await notificationsPlugin.zonedSchedule(
      name.hashCode,
      'Medication Reminder',
      'It\'s time to take $name',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Add a calendar event to remind the user to take medication
  static Future<void> addToCalendar(String name, TimeOfDay time) async {
    final permissions = await calendarPlugin.hasPermissions();
    if (!(permissions.data ?? false)) {
      await calendarPlugin.requestPermissions();
    }

    final calendarResult = await calendarPlugin.retrieveCalendars();
    final calendars = calendarResult.data;

    if (calendars == null || calendars.isEmpty) return;

    final now = DateTime.now();
    final start = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
      tz.local,
    );
    final end = start.add(const Duration(minutes: 10));

    final event = Event(
      calendars.first.id,
      title: 'Take $name',
      start: start,
      end: end,
    );

    await calendarPlugin.createOrUpdateEvent(event);
  }

  /// Convert TimeOfDay to a readable string
  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Parse a string to a TimeOfDay object
  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
