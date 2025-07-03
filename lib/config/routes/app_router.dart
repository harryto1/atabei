import 'package:atabei/core/util/not_found_page.dart';
import 'package:atabei/features/auth/presentation/pages/auth_page.dart';
import 'package:atabei/features/notifications/presentation/pages/notifications_page.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/presentation/pages/home/timeline_page.dart';
import 'package:atabei/features/timeline/presentation/pages/post_detail/post_detail_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Routes
  static const String home = '/';
  static const String login = '/login'; 
  static const String notifications = '/notifications';

  // Methods 
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => TimelinePage());
      case login: 
        return MaterialPageRoute(builder: (_) => AuthPage()); 
      case notifications: 
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      default:
        // Handle dynamic routes like /post/123
        if (settings.name?.startsWith('/post/') == true) {
          if (settings.arguments is PostEntity) {
            return MaterialPageRoute(
              builder: (_) => PostDetailPage(post: settings.arguments as PostEntity),
              settings: settings,
            );
          }
        }
        
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }
}