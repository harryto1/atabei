import 'package:atabei/config/routes/app_router.dart';
import 'package:atabei/config/theme/app_theme.dart';
import 'package:atabei/core/services/navigation_service.dart';
import 'package:atabei/dependencies.dart';
import 'package:atabei/core/services/notification_service.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDependencies();
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});

  final AppRouter appRouter; 

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(AuthInitializeRequested()), 
      child: MaterialApp(
        title: 'Atabei',
        theme: AppTheme.lightTheme, 
        darkTheme: AppTheme.darkTheme, 
        themeMode: ThemeMode.system,
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: appRouter.onGenerateRoute, 
      ),
    );
  }
}

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('🔔 Background message: ${message.notification?.title}, ${message.notification?.body}');
  try {
    NotificationService.showLocalNotification(message);
  } catch (e) {
    print(e.toString()); 
  }
}