import 'package:atabei/dependencies.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/notifications/presentation/pages/widgets/notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/components/bottom_appbar/bottom_appbar_widget.dart';
import 'package:atabei/components/drawer/drawer_widget.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:atabei/features/notifications/presentation/bloc/notification/notifications_bloc.dart';
import 'package:atabei/features/notifications/presentation/bloc/notification/notifications_event.dart';
import 'package:atabei/features/notifications/presentation/bloc/notification/notifications_state.dart';
import 'package:atabei/features/notifications/data/repositories/notifications_repository.dart';
import 'package:atabei/config/theme/timeline_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late NotificationsBloc notificationsBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    notificationsBloc = NotificationsBloc(
      notificationsRepository: sl<NotificationsRepositoryImpl>(),
    );
    
    // Start notifications stream when page loads
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      notificationsBloc.add(StartNotificationsStream(
        notificationId: '',
        userId: authState.user.uid,
        limit: 50,
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    notificationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: notificationsBloc,
      child: NotificationsView(
        tabController: _tabController,
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      notificationsBloc.add(RefreshNotifications(
        notificationId: '',
        userId: authState.user.uid,
        limit: 50,
      ));
    }
  }
}

class NotificationsView extends StatefulWidget {
  final TabController tabController;
  final VoidCallback onRefresh;

  const NotificationsView({
    super.key,
    required this.tabController,
    required this.onRefresh,
  });

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.black54,
      drawer: drawerWidget(context),
      bottomNavigationBar: bottomAppBarWidget(context, 2),
      backgroundColor: TimelineTheme.timelineBackgroundColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: Text(
            'Notifications',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: widget.tabController,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Mentions'),
            ],
          ),
        ),
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          // Handle navigation in the listener
          if (state is GotPostFromNotification && !hasNavigated) {
            hasNavigated = true; // Set flag to prevent double navigation
            
            Navigator.pushNamed(
              context, 
              '/post/${state.post.id}', 
              arguments: state.post
            ).then((_) {
              if (mounted) {
                hasNavigated = false; // Reset flag when returning
                context.read<NotificationsBloc>().add(
                  RefreshNotifications(
                    notificationId: '',
                    userId: state.post.userId,
                    limit: 50,
                  ),
                );
              }
            });
          }
          
          // Handle error notifications
          if (state is NotificationsLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GotPostFromNotification) {
            // If we got a post from notification, we don't need to show the tabs
            return const SizedBox.shrink();
          }
          return TabBarView(
            controller: widget.tabController,
            children: [
              // All notifications tab
              _buildNotificationsTab(context, state, NotificationType.all),
              // Mentions tab
              _buildNotificationsTab(context, state, NotificationType.mentions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsTab(
    BuildContext context,
    NotificationsState state,
    NotificationType type,
  ) {
    return Column(
      children: [
        // New notifications indicator
        if (state is NotificationsLoaded && state.hasNewLikes)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.blue.withOpacity(0.1),
            child: InkWell(
              onTap: () {
                context.read<NotificationsBloc>().add(LoadNewNotifications());
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
                    'Show ${state.newLikesCount} new notification${state.newLikesCount > 1 ? 's' : ''}',
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
        Expanded(
          child: _buildContent(context, state, type),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationsState state,
    NotificationType type,
  ) {
    if (state is NotificationsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notifications...'),
          ],
        ),
      );
    }

    if (state is PostLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading post...'),
          ],
        ),
      );
    }

    if (state is NotificationsError) {
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
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<NotificationsBloc>().add(
                    StartNotificationsStream(
                      notificationId: '',
                      userId: authState.user.uid,
                      limit: 50,
                    ),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    
    final likes = state is NotificationsLoaded
        ? state.likes
        : state is GotPostFromNotification
            ? state.likes
            : <LikesEntity>[];
            
    print('🔔 Building content with ${likes.length} notifications'); 

    final filteredNotifications = _filterNotifications(likes, type);
    
    print('🔔 Filtered to ${filteredNotifications.length} notifications for type: $type'); 

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              type == NotificationType.all
                  ? 'When someone likes your posts, you\'ll see it here'
                  : 'When someone mentions you, you\'ll see it here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationWidget(
              notification: notification,
              onTap: () => _onNotificationTap(context, notification),
            ),
          );
        },
      ),
    );
  }

  List<LikesEntity> _filterNotifications(List<LikesEntity> notifications, NotificationType type) {
    print('🔔 Filtering ${notifications.length} notifications'); 
    
    // For now, we're only handling likes
    switch (type) {
      case NotificationType.all:
        return notifications;
      case NotificationType.mentions:
        return []; 
    }
  }

  void _onNotificationTap(BuildContext context, LikesEntity notification) {
    print('🔔 Notification tapped: ${notification.postId}'); 

    HapticFeedback.selectionClick();
    
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationsBloc>().add(
        GetPostFromNotification(
          notification.postId, 
          notificationId: notification.id, 
          userId: authState.user.uid,
        ),
      );
    }
  }
}

enum NotificationType { all, mentions }