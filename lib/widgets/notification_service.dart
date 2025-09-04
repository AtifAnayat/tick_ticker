import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization with proper channel setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ✅ Create notification channels explicitly for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
      await _requestAllPermissions();
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse notificationResponse) {
    print('🔔 Notification tapped: ${notificationResponse.payload}');
    // Handle notification tap here - you can navigate to specific screens
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Channel 1: Task Reminders (CRITICAL IMPORTANCE for scheduled notifications)
      const AndroidNotificationChannel taskReminderChannel =
          AndroidNotificationChannel(
            'task_reminders',
            'Task Reminders',
            description: 'Notifications for upcoming tasks and notes',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          );

      // Channel 2: Task Creation
      const AndroidNotificationChannel taskCreationChannel =
          AndroidNotificationChannel(
            'task_creation',
            'Task Creation',
            description: 'Notifications when tasks or notes are created',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          );

      // Register all channels
      await androidImplementation.createNotificationChannel(taskReminderChannel);
      await androidImplementation.createNotificationChannel(taskCreationChannel);

      print('✅ Notification channels created successfully');
    }
  }

  // Request all necessary permissions (Latest version compatible)
  Future<void> _requestAllPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        // 1. Request notification permission (Android 13+)
        final notificationGranted = await androidImplementation
            .requestNotificationsPermission();
        print('📱 Notification permission: $notificationGranted');

        // 2. Check and request exact alarm permission (Android 12+)
        final canScheduleExact = await androidImplementation
            .canScheduleExactNotifications() ?? false;
        print('⏰ Can schedule exact notifications: $canScheduleExact');

        if (!canScheduleExact) {
          await _requestExactAlarmPermission();
        }

        // 3. Guide user for power optimization
        await _showBatteryOptimizationDialog();
      }
    }
  }

  // Request exact alarm permission (Critical for Android 12+)
  Future<void> _requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        
        if (androidImplementation != null) {
          // Use the new method from latest version
          await androidImplementation.requestExactAlarmsPermission();
          print('🔔 Exact alarm permission requested');
        }
      } catch (e) {
        // Fallback to intent method
        try {
          final intent = AndroidIntent(
            action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
          );
          await intent.launch();
          print('🔔 Requesting exact alarm permission via intent');
        } catch (e2) {
          print('❌ Error requesting exact alarm permission: $e2');
        }
      }
    }
  }

  // Show battery optimization dialog
  Future<void> _showBatteryOptimizationDialog() async {
    print('🔋 For reliable notifications, consider disabling battery optimization');
    // In a real app, you might want to show a dialog here
  }

  // Check if permissions were already requested
  Future<bool> hasRequestedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permissions_requested') ?? false;
  }

  // Mark permissions as requested
  Future<void> markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', true);
  }

  // Request notification permissions (only once)
  Future<bool> requestPermissions() async {
    bool hasRequested = await hasRequestedPermissions();
    if (hasRequested) {
      // Still check if exact alarms are allowed
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        
        if (androidImplementation != null) {
          final canScheduleExact = await androidImplementation
              .canScheduleExactNotifications() ?? false;
          if (!canScheduleExact) {
            await _requestExactAlarmPermission();
          }
        }
      }
      return true;
    }

    bool granted = false;

    if (Platform.isAndroid) {
      await _requestAllPermissions();
      granted = true; // Assume granted after requesting
    } else if (Platform.isIOS) {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      granted = result ?? false;
    }

    // Mark as requested regardless of the result
    await markPermissionsRequested();
    return granted;
  }

  // 🔥 FIXED: Cancel all notifications for a task using proper unique IDs
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final notificationId = taskId.hashCode.abs();
      await _notificationsPlugin.cancel(notificationId); // Main notification
      await _notificationsPlugin.cancel(notificationId + 100000); // 1-hour reminder
      print('✅ Cancelled notifications for task ID: $taskId (${notificationId})');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  // 🔥 FIXED: Schedule task notification with proper unique IDs and error handling
  Future<void> scheduleTaskNotification({
    required String id, // Changed from int to String to match TaskModel.id
    required String title,
    required DateTime dueDate,
    required bool isNote,
  }) async {
    final now = DateTime.now();

    print('🔔 Scheduling notification for: $title');
    print('📅 Due date: ${dueDate.toString()}');
    print('⏰ Current time: ${now.toString()}');
    print('📝 Is note: $isNote');

    // Only schedule if due date is in the future
    if (!dueDate.isAfter(now)) {
      print('❌ Due date is in the past, not scheduling notification');
      return;
    }

    // 🔥 FIXED: Generate unique notification ID from task ID
    final notificationId = id.hashCode.abs();
    print('🆔 Using notification ID: $notificationId');

    // First cancel any existing notifications for this task
    await cancelTaskNotifications(id);

    // Check if we can schedule exact notifications
    bool canScheduleExact = true;
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      
      if (androidImplementation != null) {
        canScheduleExact = await androidImplementation
            .canScheduleExactNotifications() ?? false;
        
        if (!canScheduleExact) {
          print('⚠️ Cannot schedule exact notifications. Requesting permission...');
          await _requestExactAlarmPermission();
          
          // Check again after requesting
          canScheduleExact = await androidImplementation
              .canScheduleExactNotifications() ?? false;
          
          if (!canScheduleExact) {
            print('⚠️ Still cannot schedule exact notifications.');
          }
        }
      }
    }

    try {
      // 🔥 FIXED: Convert DateTime to TZDateTime with proper timezone handling
      final scheduledTime = tz.TZDateTime.from(dueDate, tz.local);
      print('🕐 Scheduled time (TZ): ${scheduledTime.toString()}');

      // 1) Main notification at exact due date/time
      await _notificationsPlugin.zonedSchedule(
        notificationId, // Use the generated unique ID
        '🔔 Task Due: $title',
        isNote ? 'Your note is due now! Tap to view.' : 'Your task is due now! Tap to complete.',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming tasks and notes',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            autoCancel: false,
            ongoing: false,
            fullScreenIntent: true, // Show as full screen on lock screen
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            // ✅ Latest version supports better styling
            styleInformation: BigTextStyleInformation(
              isNote ? 'Your note "$title" is due now!' : 'Your task "$title" is due now!',
              htmlFormatBigText: true,
              contentTitle: '🔔 Task Due',
              htmlFormatContentTitle: true,
            ),
            // 🔥 ADDED: Additional settings for reliable delivery
            ticker: 'Task Due: $title',
            when: scheduledTime.millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.critical,
            categoryIdentifier: 'task_reminder_category',
          ),
        ),
        // 🔥 FIXED: Use appropriate schedule mode based on permission
        androidScheduleMode: canScheduleExact 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'task_$id',
      );

      print('✅ Scheduled main notification for: ${dueDate.toString()} with ID: $notificationId');

      // 2) Early reminder (1 hour before for same day tasks)
      final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(now) &&
          dueDate.difference(now).inHours <= 24 &&
          dueDate.difference(now).inHours >= 1) {
        
        final reminderTime = tz.TZDateTime.from(oneHourBefore, tz.local);
        final reminderNotificationId = notificationId + 100000; // Different ID
        
        await _notificationsPlugin.zonedSchedule(
          reminderNotificationId,
          '⏰ Upcoming: $title',
          isNote
              ? 'Your note is due in 1 hour!'
              : 'Your task is due in 1 hour!',
          reminderTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'task_reminders',
              'Task Reminders',
              channelDescription: 'Notifications for upcoming tasks and notes',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              icon: '@mipmap/ic_launcher',
              styleInformation: BigTextStyleInformation(
                isNote ? 'Don\'t forget! Your note "$title" is due in 1 hour.' : 'Don\'t forget! Your task "$title" is due in 1 hour.',
                htmlFormatBigText: true,
              ),
              ticker: 'Task Reminder: $title',
              when: reminderTime.millisecondsSinceEpoch,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: canScheduleExact 
              ? AndroidScheduleMode.exactAllowWhileIdle 
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'reminder_$id',
        );

        print('✅ Scheduled 1-hour reminder for: ${oneHourBefore.toString()} with ID: $reminderNotificationId');
      }

      // Verify the notification was scheduled
      await _verifyScheduledNotifications();
      
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // 🔥 FIXED: Updated method signature to accept String ID
  Future<void> cancelNotification(String id) async {
    await cancelTaskNotifications(id);
  }

  // Verify scheduled notifications (for debugging)
  Future<void> _verifyScheduledNotifications() async {
    try {
      final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
      print('📊 Total pending notifications: ${pendingNotifications.length}');
      
      for (final notification in pendingNotifications) {
        print('🔔 Pending: ID=${notification.id}, Title=${notification.title}');
      }
    } catch (e) {
      print('❌ Error verifying notifications: $e');
    }
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Show immediate notification when task/note is created
  Future<void> showTaskCreatedNotification({
    required String title,
    required bool isNote,
  }) async {
    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID based on timestamp
        isNote ? '📝 Note Created!' : '✅ Task Created!',
        isNote
            ? 'Your note "$title" has been saved successfully'
            : 'Your task "$title" has been created successfully',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_creation',
            'Task Creation',
            channelDescription: 'Notifications when tasks or notes are created',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            autoCancel: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              isNote 
                ? 'Great! Your note "$title" has been saved and is ready for you.'
                : 'Awesome! Your task "$title" has been created successfully.',
              htmlFormatBigText: true,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ Creation notification shown for: $title');
    } catch (e) {
      print('❌ Error showing creation notification: $e');
    }
  }

  // Test notification (for debugging)
  Future<void> showTestNotification() async {
    try {
      await _notificationsPlugin.show(
        999999,
        '🧪 Test Notification',
        'This is a test notification to verify the service is working',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Test notification',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ Test notification shown');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Extension to copy DateTime with new values
extension DateTimeCopyWith on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }
}