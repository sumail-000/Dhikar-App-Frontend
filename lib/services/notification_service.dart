import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';

/// Global function for handling background messages
/// This must be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Best-effort init for background isolate; ignore duplicate-app errors
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  } catch (_) {
    // ignore other already-initialized conditions
  }
  print('🔔 Background Message: ${message.messageId}');
  print('📱 Background Notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _initialized = false;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Request notification permissions (iOS)
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Push notifications permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Push notifications permission granted provisionally');
      } else {
        print('❌ Push notifications permission denied');
      }

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers
      _setupMessageHandlers();

      // Register device with backend
      await _registerDeviceWithBackend();

      _initialized = true;
      print('🚀 NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
    }
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging?.getToken();
      print('📱 FCM Token: ${_fcmToken?.substring(0, 20)}...');
      return _fcmToken;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    if (_messaging == null) return;

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground Message: ${message.messageId}');
      print('📱 Foreground Notification: ${message.notification?.title}');
      
      // Show in-app notification or update UI
      _handleForegroundMessage(message);
    });

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification tapped: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🔔 App opened from terminated state via notification: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('📱 FCM Token refreshed: ${token.substring(0, 20)}...');
      _fcmToken = token;
      _registerDeviceWithBackend();
    });
  }

  /// Register device token with Laravel backend
  Future<void> registerWithBackend() async {
    await _registerDeviceWithBackend();
  }

  Future<void> _registerDeviceWithBackend() async {
    if (_fcmToken == null) return;

    try {
      final response = await ApiClient.instance.registerDevice(
        deviceToken: _fcmToken!,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      if (response.ok) {
        print('✅ Device registered with backend successfully');
      } else {
        print('❌ Failed to register device with backend: ${response.error}');
      }
    } catch (e) {
      print('❌ Error registering device with backend: $e');
    }
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    // You can show a custom in-app notification here
    // Or update the app's UI based on the message type
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show custom notification dialog or snackbar
      print('📢 Showing foreground notification: ${notification.title}');
      
      // You can add custom logic here to show notification
      // For example, using a notification overlay or updating the notification screen
    }
  }

  /// Handle notification tap (navigate to appropriate screen)
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    // Navigate based on notification type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'group_reminder':
          // Navigate to group screen
          print('🔗 Navigating to group: ${data['group_id']}');
          break;
        case 'dhikr_group':
          // Navigate to dhikr group screen
          print('🔗 Navigating to dhikr group: ${data['dhikr_group_id']}');
          break;
        case 'motivational_verse':
          // Navigate to home screen or verse screen
          print('🔗 Navigating to motivational verse');
          break;
        default:
          // Navigate to notifications screen
          print('🔗 Navigating to notifications screen');
          break;
      }
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    return await _getFCMToken();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (_messaging == null) return false;
    
    NotificationSettings settings = await _messaging!.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permissions (mainly for iOS)
  Future<bool> requestPermission() async {
    if (_messaging == null) return false;

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Unregister device from backend (call on logout)
  Future<void> unregisterDevice() async {
    if (_fcmToken == null) return;

    try {
      final response = await ApiClient.instance.unregisterDevice(
        deviceToken: _fcmToken!,
      );

      if (response.ok) {
        print('✅ Device unregistered from backend successfully');
      } else {
        print('❌ Failed to unregister device from backend: ${response.error}');
      }
    } catch (e) {
      print('❌ Error unregistering device from backend: $e');
    }
  }

  /// Subscribe to topic (for group notifications)
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    
    try {
      await _messaging!.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get notification navigation context
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Navigate to screen from notification
  static void navigateToScreen(String route, {Map<String, dynamic>? arguments}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    }
  }
}
