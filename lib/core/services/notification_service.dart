import 'package:atabei/core/services/navigation_service.dart';
import 'package:atabei/dependencies.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = sl<FirebaseMessaging>(); 
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = sl<FirebaseFirestore>();
  static final FirebaseAuth _auth = sl<FirebaseAuth>();

  static Future<void> initialize() async {
    await _requestPermissions();

    await _initializeLocalNotifications();

    await _configureFCM();

    // Save the FCM token to Firestore
    await saveFcmToken();
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User allowed notifications');
    } else {
      print('❌ User denied notifications');
    }
  }

  // Set up local notifications for foreground messages
  static Future<void> _initializeLocalNotifications() async {
    // Android settings with the app icon
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize local notifications with a tap handler
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print('Tapped notification with payload: ${response.payload}');
          _navigateToNotifications(); 
        }
      },
    );

    // Create a notification channel for Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'likes_channel',
        'Likes Notifications',
        description: 'Notifications for post likes',
        importance: Importance.high,
      ),
    );
  }

  // Configure FCM to handle messages
  static Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(message);
      }
    });

    // Handle taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened notification: ${message.data}');
      _navigateToNotifications();

    });

    // Handle taps when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated: ${initialMessage.data}');
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToNotifications();
      }); 
    }
  }

  // Show a local notification for foreground messages
  static Future<void> showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'likes_channel',
      'Likes Notifications',
      channelDescription: 'Notifications for post likes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.messageId.hashCode, // Unique ID for the notification
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'Something happened!',
      details,
      payload: message.data['postId'], // Store postId for navigation
    );
  }

  static void _navigateToNotifications() {
    print('🔔 Navigating to notifications page');
    
    try {
      NavigationService.navigateToReplacement('/notifications');
    } catch (e) {
      print('❌ Error navigating to notifications: $e');
    }
  }

  // Save the user's FCM token to Firestore
  static Future<void> saveFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      User? user = _auth.currentUser;
      if (token != null && user != null) {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        Map<String, dynamic> defaultFields = {
          'fcmToken': token,
          'username': user.displayName ?? '',
          'bio': '',
          'pathToProfilePicture': user.photoURL ?? '',
          'location': '',
          'birthdate': '',
          'dateJoined': user.metadata.creationTime,
          'isPrivate': false,
        };

        if (!userDoc.exists) {
          // If document doesn't exist, set all fields
          await userDocRef.set(defaultFields);
        } else {
          // If document exists, only set missing fields and always update fcmToken
          Map<String, dynamic> updates = {'fcmToken': token};
          defaultFields.forEach((key, value) {
            if (!userDoc.data()!.containsKey(key)) {
              updates[key] = value;
            }
          });
          if (updates.length > 1) {
            await userDocRef.update(updates);
          } else {
            // Only fcmToken needs update
            await userDocRef.update({'fcmToken': token});
          }
        }
        print('✅ FCM token saved: $token');
      } else {
        print('❌ No user signed in or token is null');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }
}