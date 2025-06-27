import 'package:flutter/material.dart';

class ThemeHelper {
  
  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
  
  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }
  
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}