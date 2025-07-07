import 'package:atabei/dependencies.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:atabei/features/profile/presentation/cubit/profile/profile_state.dart';
import 'package:atabei/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/components/bottom_appbar/bottom_appbar_widget.dart';
import 'package:atabei/components/drawer/drawer_widget.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_bloc.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';
import 'package:atabei/features/timeline/presentation/widgets/post_widget.dart';
import 'package:atabei/config/theme/timeline_theme.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, show current user's profile

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileCubit profileCubit;
  late TimelineBloc timelineBloc;
  String? targetUserId;

  @override
  void initState() {
    super.initState();
    
    // Initialize cubits/blocs
    profileCubit = sl<ProfileCubit>();
    // profileCubit.loadProfile(widget.userId);
    
    timelineBloc = TimelineBloc();
    
    // Get target user ID and load data
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      targetUserId = widget.userId ?? authState.user.uid;
      
      print('🔍 Loading profile for user: $targetUserId');
      
      profileCubit.loadProfile(targetUserId!);
      
      timelineBloc.add(StartTimelineStreamFromAuthor(
        authorId: targetUserId!,
        limit: 50,
      ));
    }
  }

  @override
  void dispose() {
    profileCubit.close();
    timelineBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileCubit),
        BlocProvider.value(value: timelineBloc),
      ],
      child: Scaffold(
        backgroundColor: TimelineTheme.timelineBackgroundColor(context),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
        drawer: drawerWidget(context), 
        bottomNavigationBar: bottomAppBarWidget(context, 3),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                
                const SizedBox(height: 20),
                
                _buildPostsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (state is ProfileError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (targetUserId != null) {
                      profileCubit.loadProfile(targetUserId!);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is ProfileLoaded) {
          final profile = state.userProfile;
          
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (profile.pathToProfilePicture != null && profile.pathToProfilePicture!.isNotEmpty)
                    ? NetworkImage(profile.pathToProfilePicture!)
                    : null,
                  backgroundColor: Colors.grey[300],
                  child: (profile.pathToProfilePicture == null || profile.pathToProfilePicture!.isEmpty)
                    ? Text(
                      profile.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
                ),
                
                const SizedBox(height: 16),
                
                // Username
                Text(
                  profile.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bio
                if (profile.bio != null && profile.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      profile.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Location
                if (profile.location != null && profile.location!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.location!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 8),
                
                // Join Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Joined ${_formatDate(profile.dateJoined)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Edit Profile Button
                _buildCurrentUserProfileButton(),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrentUserProfileButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated && 
            (targetUserId == null || targetUserId == authState.user.uid)) {
          // This is the current user's profile
          return OutlinedButton(
            onPressed: () {
              _showEditProfileDialog();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          );
        }
        
        // This is another user's profile - show follow button
        return ElevatedButton(
          onPressed: () {
            _showFollowDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: const Text(
            'Follow',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsSection() {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state is TimelineLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (state is TimelineError) {
          String errorMessage = state.message;
          bool isIndexError = errorMessage.toLowerCase().contains('index') || 
                             errorMessage.toLowerCase().contains('precondition');
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  isIndexError ? Icons.build : Icons.error,
                  size: 48,
                  color: isIndexError ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 8),
                Text(
                  isIndexError 
                      ? 'Setting up database...' 
                      : 'Failed to load posts',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isIndexError
                      ? 'Please wait while we prepare your profile. This may take a few minutes.'
                      : errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _onRefresh();
                  },
                  child: Text(isIndexError ? 'Check Again' : 'Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is TimelineLoaded) {
          if (state.posts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.post_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Posts will appear here when created',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posts Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Posts (${state.posts.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Posts List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        return PostWidget(
                          post: post,
                          timelineBloc: context.read<TimelineBloc>(),
                          isLiking: false,
                          onLike: authState is AuthAuthenticated
                              ? () {
                                  final username = authState.user.displayName;
                                  
                                  context.read<TimelineBloc>().add(
                                    LikePost(
                                      postId: post.id,
                                      userId: authState.user.uid,
                                      username: username,
                                    ),
                                  );
                                }
                              : null,
                          onTap: () {
                            print('Tapped on post: ${post.id}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _onRefresh() async {
    if (targetUserId != null) {
      print('🔄 Refreshing profile data...');
      await profileCubit.refreshProfile(targetUserId!);
      timelineBloc.add(RefreshTimelineFromAuthor(
        authorId: targetUserId!,
        limit: 50,
      ));
    }
  }

  void _showEditProfileDialog() {
    final currentState = profileCubit.state;
    if (currentState is ProfileLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: profileCubit,
            child: EditProfilePage(userProfile: currentState.userProfile),
          ),
        ),
      ).then((result) {
        if (result != null && targetUserId != null) {
          print('🔄 Profile updated, refreshing with result: ${result.runtimeType}');
          
          if (result is UserProfileEntity) {
            print('🔄 Updating cubit with new profile data');
            profileCubit.updateProfile(result);
          } else if (result == true) {
            // Fallback: refresh from server
            print('🔄 Refreshing profile from server');
            profileCubit.refreshProfile(targetUserId!);
          }
        }
      });
    }
  }

  void _showFollowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Follow User'),
        content: const Text('Follow functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}