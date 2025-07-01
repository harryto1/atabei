import 'dart:io';

import 'package:atabei/core/resources/data_state.dart';

abstract class LocalImageRepository {
  Future<DataState<String>> uploadPostImage(File imageFile, String postId);
  Future<DataState<void>> deletePostImage(String imagePath);
  Future<List<String>> getPostImages(String postId);
  Future<void> cleanupOldImages({int maxAgeInDays = 3}); 
}