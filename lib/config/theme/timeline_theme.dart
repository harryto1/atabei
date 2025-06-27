import 'package:flutter/material.dart';
import 'app_theme.dart';

class TimelineTheme {
  static const Color timelineAccent = Color(0xFF3B82F6);
  static const Color timelineBackground = Color(0xFFF1F5F9);
  static const Color darkTimelineBackground = Color(0xFF111827);
  
  // Timeline specific styles that adapt to theme
  static BoxDecoration timelineCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark 
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  static TextStyle timelineTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : const Color(0xFF1F2937),
    );
  }
  
  static TextStyle timelineSubtitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 14,
      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
    );
  }
  
  static TextStyle timelineTimestampStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 12,
      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
      fontWeight: FontWeight.w500,
    );
  }
  
  // Additional adaptive colors
  static Color timelineIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? timelineAccent.withOpacity(0.8) : timelineAccent;
  }
  
  static Color timelineBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }
  
  static Color timelineBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTimelineBackground : timelineBackground;
  }
}