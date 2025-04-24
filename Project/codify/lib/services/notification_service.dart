import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../user/user_service.dart';
import 'auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  final String _androidChannelId = 'high_importance_channel';
  final String _androidChannelName = 'High Importance Notifications';
  final String _androidChannelDescription =
      'This channel is used for important notifications.';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    if (kDebugMode) {
      print('[NotificationService] Timezones initialized.');
    }

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      print(
          '[NotificationService] FCM Permission status: ${settings.authorizationStatus}');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    bool? initialized = await _flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    if (kDebugMode) {
      print(
          '[NotificationService] Local notifications plugin initialized: $initialized');
    }

    await _createAndroidNotificationChannel();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    await _saveFcmToken();

    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveFcmToken(token: newToken);
    });
  }

  Future<void> _createAndroidNotificationChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    );

    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      if (kDebugMode) {
        print(
            '[NotificationService] Android notification channel created successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '[NotificationService] Error creating Android notification channel: $e');
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("Foreground Message received:");
    print("Notification Title: ${message.notification?.title}");
    print("Notification Body: ${message.notification?.body}");
    print("Data Payload: ${message.data}");

    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> _saveFcmToken({String? token}) async {
    final fcmToken = token ?? await _fcm.getToken();
    print('FCM Token: $fcmToken');
    final uid = await _authService.getUID();

    if (uid != null && fcmToken != null) {
      try {
        final users = await _userService.getUserByUserId(uid);
        if (users.isNotEmpty) {
          final user = users.first;

          if (user.fcmToken != fcmToken) {
            print('Updating FCM token for user $uid');
            user.fcmToken = fcmToken;
            await _userService.updateUser(user);
          } else {
            print('FCM token is already up-to-date.');
          }
        } else {
          print('User not found for UID: $uid. Cannot save FCM token.');
        }
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    } else {
      print('UID or FCM Token is null. Cannot save token.');
    }
  }

  Future<void> refreshToken() async {
    print('Manual FCM token refresh requested.');
    await _saveFcmToken();
  }

  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (kDebugMode) {
      print(
          '[NotificationService] Attempting to schedule notification ID: $id');
      print('[NotificationService] Raw scheduledDateTime: $scheduledDateTime');
    }

    if (scheduledDateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print(
            '[NotificationService] Error: Scheduled time $scheduledDateTime is in the past.');
      }
      return;
    }

    tz.TZDateTime scheduledDate;
    try {
      scheduledDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );
      if (kDebugMode) {
        print(
            '[NotificationService] Converted scheduledDate (TZDateTime): $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '[NotificationService] Error converting DateTime to TZDateTime: $e');
      }
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFFFFFFFFF),
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      if (kDebugMode) {
        print(
            '[NotificationService] Calling zonedSchedule for ID $id at $scheduledDate');
      }
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      if (kDebugMode) {
        print(
            '[NotificationService] Successfully scheduled notification $id for $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '[NotificationService] Error calling zonedSchedule for notification $id: $e');
      }
    }
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('Cancelled scheduled notification $id');
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all scheduled notifications');
  }
}
