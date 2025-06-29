import 'package:atabei/core/util/not_found_page.dart';
import 'package:atabei/features/auth/presentation/pages/auth_page.dart';
import 'package:atabei/features/timeline/presentation/pages/home/timeline_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Define your routes here
  static const String home = '/';
  static const String login = '/login'; 

  // Methods 
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => TimelinePage());
      case login: 
        return MaterialPageRoute(builder: (_) => AuthPage()); 
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  }
}