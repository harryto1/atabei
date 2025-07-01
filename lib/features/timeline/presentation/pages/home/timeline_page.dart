import 'dart:io';
import 'package:atabei/components/appbar/appbar_widget.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:atabei/features/timeline/data/repositories/local_image_repository.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_bloc.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';
import 'package:atabei/features/timeline/presentation/widgets/post_widget.dart';
import 'package:atabei/features/timeline/data/repositories/post_repository.dart';
import 'package:atabei/config/theme/timeline_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  File? selectedImage;
  final TextEditingController contentController = TextEditingController();
  late TimelineBloc timelineBloc;

  @override
  void initState() {
    super.initState();
    timelineBloc = TimelineBloc(
      postsRepository: PostRepositoryImpl(),
      localImageRepository: LocalImageRepositoryImpl(),
    )..add(const StartTimelineStream());
  }

  @override
  void dispose() {
    contentController.dispose();
    timelineBloc.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: timelineBloc, 
      child: TimelineView(onCreatePost: () => _showCreatePostDialog(context)),
    );
  }

  Future<void> _pickImage() async {
    try {
      if (await Permission.photos.request().isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please allow photo access to pick an image')),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
        print('✅ Image selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    // Reset state
    contentController.clear();
    selectedImage = null;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(
                  maxWidth: 400, 
                  maxHeight: 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.create,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create Post',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: contentController,
                                decoration: const InputDecoration(
                                  hintText: 'What\'s on your mind?',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                maxLines: 3,
                                maxLength: 280,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            if (selectedImage != null) ...[
                              Stack(
                                children: [
                                  Container(
                                    height: 120, 
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 16,
                                      child: IconButton(
                                        onPressed: () {
                                          selectedImage = null;
                                          setDialogState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await _pickImage();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.photo_library, size: 18),
                                    label: const Text('Gallery'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await _pickImageFromCamera();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('Camera'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (contentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter some text')),
                                );
                                return;
                              }

                              final userAuth = context.read<AuthBloc>().state;
                              if (userAuth is AuthAuthenticated) {
                                final post = PostEntity(
                                  id: '',
                                  userId: userAuth.user.uid,
                                  username: userAuth.user.displayName,
                                  content: contentController.text.trim(),
                                  pathToProfilePicture: null,
                                  pathToImage: selectedImage?.path,
                                  dateOfPost: DateTime.now(),
                                  likes: 0,
                                  comments: 0,
                                  reposts: 0,
                                  bookmarks: 0,
                                );

                                timelineBloc.add(
                                  CreatePost(post: post, imageFile: selectedImage),
                                );
                                
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            child: const Text('Post'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (await Permission.camera.request().isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please allow camera access to take a photo')),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
        print('✅ Photo taken: ${image.path}');
      }
    } catch (e) {
      print('❌ Error taking photo: $e');
    }
  }
}

class TimelineView extends StatelessWidget {
  final VoidCallback? onCreatePost;
  
  const TimelineView({super.key, this.onCreatePost});

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
          if (context.read<AuthBloc>().state is! AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to create a post.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          onCreatePost?.call(); // Call the parent's dialog function
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
          context.read<AuthBloc>().add(AuthCheckRequested());
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
                  final userAuth = context.read<AuthBloc>().state;
                  if (userAuth is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to like a post.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  } else {
                    final user = userAuth.user;
                    context.read<TimelineBloc>().add(
                      LikePost(postId: post.id, userId: user.uid),
                    );
                  } 
                },
                onUnlike: () {
                  final userAuth = context.read<AuthBloc>().state;
                  if (userAuth is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to unlike a post.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  } else {
                    final user = userAuth.user;
                    context.read<TimelineBloc>().add(
                      UnlikePost(postId: post.id, userId: user.uid),
                    );
                  }
                },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
} 