import 'package:atabei/core/services/navigation_service.dart';
import 'package:atabei/core/services/notification_service.dart';
import 'package:atabei/features/auth/data/repositories/auth_repository.dart';
import 'package:atabei/features/notifications/data/repositories/notifications_repository.dart';
import 'package:atabei/features/profile/data/repositories/user_profile_repository.dart';
import 'package:atabei/features/profile/domain/usecases/delete_user_profile.dart';
import 'package:atabei/features/profile/domain/usecases/fetch_user_profile.dart';
import 'package:atabei/features/profile/domain/usecases/update_user_profile.dart';
import 'package:atabei/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:atabei/features/search/domain/usecases/search_user_profiles.dart';
import 'package:atabei/features/timeline/data/repositories/local_image_repository.dart';
import 'package:atabei/features/timeline/data/repositories/post_repository.dart';
import 'package:atabei/features/timeline/domain/usecases/create_post.dart';
import 'package:atabei/features/timeline/domain/usecases/delete_post.dart';
import 'package:atabei/features/timeline/domain/usecases/get_post_stream.dart';
import 'package:atabei/features/timeline/domain/usecases/get_posts.dart';
import 'package:atabei/features/timeline/domain/usecases/get_posts_by_author.dart';
import 'package:atabei/features/timeline/domain/usecases/get_posts_by_author_stream.dart';
import 'package:atabei/features/timeline/domain/usecases/get_posts_stream.dart';
import 'package:atabei/features/timeline/domain/usecases/like_post.dart';
import 'package:atabei/features/timeline/domain/usecases/unlike_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  // Core services
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Firebase services
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance); 
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Timeline 
  sl.registerLazySingleton<PostRepositoryImpl>(() => PostRepositoryImpl(firestore: sl<FirebaseFirestore>()));
  sl.registerLazySingleton<LocalImageRepositoryImpl>(() => LocalImageRepositoryImpl()); 

  // Search
  sl.registerLazySingleton<UserProfileRepositoryImpl>(() => UserProfileRepositoryImpl(firestore: sl<FirebaseFirestore>()));

  // Profile
  sl.registerFactory<ProfileCubit>(() => ProfileCubit());

  // Notifications
  sl.registerLazySingleton<NotificationsRepositoryImpl>(() => NotificationsRepositoryImpl(firestore: sl<FirebaseFirestore>()));

  // Auth
  sl.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(firebaseAuth: sl<FirebaseAuth>()));

  // Use Cases - Timeline
  sl.registerFactory<CreatePostUseCase>(() => CreatePostUseCase(sl<PostRepositoryImpl>(), sl<LocalImageRepositoryImpl>()));
  sl.registerFactory<DeletePostUseCase>(() => DeletePostUseCase(sl<PostRepositoryImpl>(), sl<LocalImageRepositoryImpl>()));
  sl.registerFactory<LikePostUseCase>(() => LikePostUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<UnlikePostUseCase>(() => UnlikePostUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<GetPostStreamUseCase>(() => GetPostStreamUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<GetPostsStreamUseCase>(() => GetPostsStreamUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<GetPostsByAuthorStreamUseCase>(() => GetPostsByAuthorStreamUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<GetPostsByAuthorUseCase>(() => GetPostsByAuthorUseCase(sl<PostRepositoryImpl>()));
  sl.registerFactory<GetPostsUseCase>(() => GetPostsUseCase(sl<PostRepositoryImpl>()));
  
  // Use Cases - Profile 
  sl.registerFactory<UpdateUserProfileUseCase>(() => UpdateUserProfileUseCase(sl<UserProfileRepositoryImpl>()));
  sl.registerFactory<DeleteUserProfileUseCase>(() => DeleteUserProfileUseCase(sl<UserProfileRepositoryImpl>()));
  sl.registerFactory<FetchUserProfileUseCase>(() => FetchUserProfileUseCase(sl<UserProfileRepositoryImpl>()));

  // Use Cases - Search
  sl.registerFactory<SearchUserProfilesUseCase>(() => SearchUserProfilesUseCase(sl<UserProfileRepositoryImpl>()));
}