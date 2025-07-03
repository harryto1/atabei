import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';

class NotificationWidget extends StatelessWidget {
  final LikesEntity notification;
  final VoidCallback? onTap;

  const NotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildNotificationDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification text
                    _buildNotificationText(context),
                    const SizedBox(height: 4),
                    
                    // Timestamp
                    Text(
                      timeago.format(notification.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action button (optional)
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildNotificationDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    // For now, we're handling likes
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.favorite,
        color: Colors.red,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationText(BuildContext context) {
    // For now, we're handling likes. 
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: notification.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const TextSpan(text: ' liked your post'),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.more_vert,
        size: 16,
        color: Colors.grey,
      ),
      onPressed: () => _showNotificationOptions(context),
    );
  }

  void _showNotificationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('Hide this notification'),
              onTap: () {
                Navigator.pop(context);
                // Handle hide notification
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Turn off notifications from this person'),
              onTap: () {
                Navigator.pop(context);
                // Handle turn off notifications
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Handle report
              },
            ),
          ],
        ),
      ),
    );
  }
}