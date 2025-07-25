import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication_model.dart';

class MedicationReminderPage extends StatefulWidget {
  const MedicationReminderPage({super.key});

  @override
  State<MedicationReminderPage> createState() => _MedicationReminderPageState();
}

class _MedicationReminderPageState extends State<MedicationReminderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();

  List<Medication> _medications = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _fetchMedications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _fetchMedications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('medications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('time')
        .get();

    setState(() {
      _medications = snapshot.docs
          .map((doc) => Medication.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> _addOrEditMedication({Medication? med}) async {
    final nameController = TextEditingController(text: med?.name ?? '');
    TimeOfDay selectedTime = med != null
        ? TimeOfDay.fromDateTime(med.time)
        : TimeOfDay.now();

    bool timePicked = med != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(med != null ? 'Edit Medication' : 'Add Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                    timePicked = true;
                  });
                }
              },
              child: const Text('Select Time'),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final now = DateTime.now();
              final time = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
              final userId = _auth.currentUser?.uid;

              if (userId == null || name.isEmpty || !timePicked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter name and select time.")));
                return;
              }

              if (med != null) {
                await _firestore.collection('medications').doc(med.id).update({
                  'name': name,
                  'time': Timestamp.fromDate(time),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Medication updated.")));
              } else {
                final newDoc = await _firestore.collection('medications').add({
                  'userId': userId,
                  'name': name,
                  'time': Timestamp.fromDate(time),
                  'taken': false,
                  'timestamp': Timestamp.now(),
                });

                await _scheduleNotification(name, selectedTime);
                await _addToCalendar(name, selectedTime);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Medication saved and reminder scheduled.")));
              }

              Navigator.pop(context);
              _fetchMedications();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _scheduleNotification(String name, TimeOfDay time) async {
    final android = AndroidNotificationDetails(
      'meds_id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platform = NotificationDetails(android: android);

    final now = DateTime.now();
    final scheduledTime = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await _notificationsPlugin.zonedSchedule(
      name.hashCode,
      'Medication Reminder',
      'Time to take $name',
      scheduledTime,
      platform,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _addToCalendar(String name, TimeOfDay time) async {
    final permissions = await _calendarPlugin.hasPermissions();
    if (!(permissions.data ?? false)) {
      await _calendarPlugin.requestPermissions();
    }

    final calendars = await _calendarPlugin.retrieveCalendars();
    final calendarList = calendars.data;

    if (calendarList == null || calendarList.isEmpty) return;

    final now = DateTime.now();
    // Convert to TZDateTime for the local timezone
    final start = tz.TZDateTime.local(
      now.year, 
      now.month, 
      now.day, 
      time.hour, 
      time.minute
    );
    final end = start.add(const Duration(minutes: 10));

    final event = Event(
      calendarList.first.id,
      title: 'Take $name',
      start: start,
      end: end,
    );

    await _calendarPlugin.createOrUpdateEvent(event);
  }

  Future<void> _markAsTaken(Medication med) async {
    final updated = med.copyWith(taken: true, takenTime: DateTime.now());

    await _firestore.collection('medications').doc(med.id).update({
      'taken': true,
      'takenTime': Timestamp.fromDate(updated.takenTime!),
    });

    await _firestore.collection('medication_history').add({
      'name': med.name,
      'takenAt': Timestamp.fromDate(updated.takenTime!),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked ${med.name} as taken')));

    _fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditMedication(),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onDaySelected: (selectedDay, focusedDay) =>
                setState(() => _focusedDay = focusedDay),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                final timeStr = DateFormat.Hm().format(med.time);

                return ListTile(
                  title: Text(med.name),
                  subtitle: Text('Time: $timeStr'),
                  trailing: med.taken
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _markAsTaken(med),
                        ),
                  onTap: () => _addOrEditMedication(med: med),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}