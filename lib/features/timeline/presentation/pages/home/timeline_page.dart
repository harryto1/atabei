import 'package:atabei/components/appbar/appbar_widget.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_bloc.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';
import 'package:atabei/features/timeline/presentation/widgets/post_widget.dart';
import 'package:atabei/features/timeline/data/repositories/post_repository.dart';
import 'package:atabei/config/theme/timeline_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<AuthBloc>()),
        BlocProvider(
          create:
              (context) =>
                  TimelineBloc(postsRepository: PostRepositoryImpl())
                    ..add(const StartTimelineStream()),
        ),
      ],
      child: const TimelineView(),
    );
  }
}

class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimelineTheme.timelineBackgroundColor(context),
      appBar: appBarWidget(),
      body: BlocConsumer<TimelineBloc, TimelineState>(
        listener: (context, state) {
          if (state is TimelineLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // New posts indicator
              if (state is TimelineLoaded && state.hasNewPosts)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.blue.withOpacity(0.1),
                  child: InkWell(
                    onTap: () {
                      context.read<TimelineBloc>().add(const RefreshTimeline());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Show ${state.newPostsCount} new post${state.newPostsCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TimelineState state) {
    if (state is TimelineLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TimelineError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TimelineBloc>().add(const StartTimelineStream());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is TimelineLoaded) {
      if (state.posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timeline,
                size: 64,
                color: Colors.grey.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share something!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<TimelineBloc>().add(const RefreshTimeline());
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            final post = state.posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostWidget(
                post: post,
                isLiking:
                    state is TimelinePostLiking &&
                    (state as TimelinePostLiking).postId == post.id,
                onLike: () {
                  const String currentUserId = 'current_user_id';
                  context.read<TimelineBloc>().add(
                    LikePost(postId: post.id, userId: currentUserId),
                  );
                },
                onUnlike: () {
                  const String currentUserId = 'current_user_id';
                  context.read<TimelineBloc>().add(
                    UnlikePost(postId: post.id, userId: currentUserId),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final usernameController = TextEditingController();
        final contentController = TextEditingController();

        return AlertDialog(
          title: const Text('Create Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your username',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                  hintText: 'Share your thoughts...',
                ),
                maxLines: 3,
                maxLength: 280,
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: This is a simple demo. In a real app, username would come from authentication.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  final post = PostEntity(
                    id: '',
                    userId: 123,
                    username: usernameController.text.trim(),
                    content: contentController.text.trim(),
                    pathToProfilePicture: null,
                    dateOfPost: DateTime.now(),
                    likes: 0,
                    comments: 0,
                    reposts: 0,
                    bookmarks: 0,
                  );

                  context.read<TimelineBloc>().add(CreatePost(post: post));
                  Navigator.of(dialogContext).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  String errorMessage = '';
                  if (usernameController.text.isEmpty) {
                    errorMessage = 'Please enter a username';
                  } else if (contentController.text.isEmpty) {
                    errorMessage = 'Please enter some content';
                  }

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
