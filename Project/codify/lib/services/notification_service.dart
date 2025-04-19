import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../user/user_service.dart';
import 'auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle notifications when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Save the FCM token to the user profile
    await _saveFcmToken();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> _saveFcmToken() async {
    final token = await _fcm.getToken();
    print('FCM Token: $token');
    final uid = await _authService.getUID();

    if (uid != null && token != null) {
      try {
        final users = await _userService.getUserByUserId(uid);
        if (users.isNotEmpty) {
          final user = users.first;
          // Update user's FCM token
          user.fcmToken = token;
          await _userService.updateUser(user);
        }
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  Future<void> refreshToken() async {
    await _saveFcmToken();
  }

  Future<void> testForegroundNotification() async {
    print('Simulating foreground notification...');
    await _handleForegroundMessage(
      const RemoteMessage(
        notification: RemoteNotification(
          title: 'Test Title',
          body: 'This is a test foreground notification body.',
        ),
        // Add a dummy messageId or other fields if your handler expects them
      ),
    );
    print('Simulation complete.');
  }
}
