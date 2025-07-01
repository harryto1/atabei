import 'package:flutter/material.dart';

Widget commentWidget(BuildContext context, int index) {
    final usernames = ['john_doe', 'jane_smith', 'alex_dev'];
    final comments = [
      'Great post! Thanks for sharing this.',
      'Really interesting perspective on this topic.',
      'I completely agree with your point here.',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(usernames[index].substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      usernames[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${index + 1}h',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comments[index]),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }