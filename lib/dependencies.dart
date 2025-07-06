import 'package:atabei/core/services/navigation_service.dart';
import 'package:atabei/core/services/notification_service.dart';
import 'package:atabei/features/auth/data/repositories/auth_repository.dart';
import 'package:atabei/features/notifications/data/repositories/notifications_repository.dart';
import 'package:atabei/features/profile/data/repositories/user_profile_repository.dart';
import 'package:atabei/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:atabei/features/timeline/data/repositories/local_image_repository.dart';
import 'package:atabei/features/timeline/data/repositories/post_repository.dart';
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
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(userProfileRepository: sl<UserProfileRepositoryImpl>()));

  // Notifications
  sl.registerLazySingleton<NotificationsRepositoryImpl>(() => NotificationsRepositoryImpl(firestore: sl<FirebaseFirestore>()));

  // Auth
  sl.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(firebaseAuth: sl<FirebaseAuth>()));

  


}