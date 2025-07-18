import 'dart:io';

import 'package:atabei/config/theme/timeline_theme.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_bloc.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatelessWidget {
  final PostEntity post;
  final TimelineBloc timelineBloc; 
  final Function()? onLike;
  final Function()? onUnlike;
  final Function()? onTap; 
  final bool isLiking;

  const PostWidget({
    super.key,
    required this.timelineBloc,
    required this.post,
    this.onLike,
    this.onUnlike,
    this.onTap, 
    this.isLiking = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        decoration: TimelineTheme.timelineCardDecoration(context),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: post.pathToProfilePicture != null
                          ? NetworkImage(post.pathToProfilePicture!)
                          : null,
                      child: post.pathToProfilePicture == null
                          ? Text(post.username.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: TimelineTheme.timelineTitleStyle(context),
                          ),
                          Text(
                            timeago.format(post.dateOfPost),
                            style: TimelineTheme.timelineTimestampStyle(context),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Show post options
                        _showPostOptions(context);
                      },
                    ),
                  ],
                ),
              ),
              
              // Post content - Now using the actual content property
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the actual post content
                    Text(
                      post.content,
                      style: TimelineTheme.timelineSubtitleStyle(context).copyWith(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (post.pathToImage != null && post.pathToImage?.substring(0, 4) == 'http') 
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.network(
                          post.pathToImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => 
                            const Text('Image not available'),
                        ),
                      ),
                    if (post.pathToImage != null && post.pathToImage?.substring(0, 4) != 'http') 
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.file(
                          File(post.pathToImage!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => 
                            const Text('Image not available'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Optional: Show post timestamp
                    Text(
                      '${_formatDate(post.dateOfPost)} at ${_formatTime(post.dateOfPost)}',
                      style: TimelineTheme.timelineTimestampStyle(context).copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Post actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: isLiking ? null : () {
                        onLike?.call();
                      },
                      child: Row(
                        children: [
                          if (isLiking)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 20,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likes}',
                            style: TimelineTheme.timelineTimestampStyle(context),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Comment button
                    InkWell(
                      onTap: () {
                        _navigateToComments(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: TimelineTheme.timelineIconColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.comments}',
                            style: TimelineTheme.timelineTimestampStyle(context),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Repost button
                    InkWell(
                      onTap: () {
                        _handleRepost(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            color: TimelineTheme.timelineIconColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.reposts}',
                            style: TimelineTheme.timelineTimestampStyle(context),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bookmark button
                    InkWell(
                      onTap: () {
                        _handleBookmark(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: TimelineTheme.timelineIconColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.bookmarks}',
                            style: TimelineTheme.timelineTimestampStyle(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Handle report
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // Handle block
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder:(context, state) {
                if (state is AuthAuthenticated && state.user.uid == post.userId) {
                  return ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete Post'),
                    onTap: () {
                      timelineBloc.add(
                        DeletePost(postId: post.id, imageFile: post.pathToImage != null && post.pathToImage!.substring(0, 4) != 'http' ? File(post.pathToImage!) : null),
                      ); 
                      Navigator.pop(context);
                    },
                  );
                }
                return const SizedBox.shrink(); // Hide delete option if not authenticated
              },
            )
          ],
        ),
      ),
    );
  }

  void _navigateToComments(BuildContext context) {
    // Navigate to comments page
    // Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsPage(postId: post.id)));
  }

  void _handleRepost(BuildContext context) {
    // Handle repost functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repost functionality not implemented yet')),
    );
  }

  void _handleBookmark(BuildContext context) {
    // Handle bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark functionality not implemented yet')),
    );
  }
}