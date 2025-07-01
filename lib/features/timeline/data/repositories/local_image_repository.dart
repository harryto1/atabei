import 'dart:async';
import 'dart:io';

import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/timeline/domain/repositories/local_image_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalImageRepositoryImpl implements LocalImageRepository {

  static const String _imagesFolderName = 'post_images';

  @override
  Future<void> cleanupOldImages({int maxAgeInDays = 3}) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocDir.path}/$_imagesFolderName');

      if (!imagesDir.existsSync()) {
        print('📂 Images directory does not exist, skipping cleanup');
        return;
      }

      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
      final postFolders = imagesDir.listSync().whereType<Directory>();
      for (final folder in postFolders) {
        final String postId = folder.path.split('/').last;
        final List<FileSystemEntity> files = folder.listSync();

        if (files.isEmpty) {
          print('🗑️ Deleting empty post folder: $postId');
          await folder.delete(recursive: true);
          continue;
        }

        for (final file in files) {
          if (file is File) {
            final DateTime lastModified = await file.lastModified();
            if (lastModified.isBefore(cutoffDate)) {
              print('🗑️ Deleting old image: ${file.path}');
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      print('❌ Image cleanup failed: $e');
      throw Exception('Failed to cleanup old images: $e');
    }
  }

  @override
  Future<DataState<void>> deletePostImage(String imagePath) async {
    try {
      print('🗑️ Deleting local image: $imagePath');

      final File imageFile = File(imagePath);

      if (await imageFile.exists()) {
        await imageFile.delete();
        print('✅ Local image deleted successfully');
      }

      return const DataSuccess(null); 

    } catch (e) {
      print('❌ Local image deletion failed: $e');
      return DataError(ImageException(message: 'Failed to delete local image: $e'));
    }
  }

  @override
  Future<List<String>> getPostImages(String postId) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocDir.path}/$_imagesFolderName/$postId');

      if (!imagesDir.existsSync()) {
        return [];
      }

      final List<FileSystemEntity> files = await imagesDir.list().toList(); 
      return files
        .whereType<File>()
        .map((file) => file.path)
        .toList(); 


    } catch (e) {
      print('❌ Failed to get local images: $e');
      return [];
    }
  }

  @override
  Future<DataState<String>> uploadPostImage(File imageFile, String postId) async {
    try {
      print('📸 Saving image locally for post: $postId');

      final Directory appDocDir = await getApplicationDocumentsDirectory();

      final Directory imagesDir = Directory('${appDocDir.path}/$_imagesFolderName/$postId');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final String fileName = '${postId}_${const Uuid().v4()}.${imageFile.path.split('.').last}';
      final String localPath = '${imagesDir.path}/$fileName';

      // Copy file to local directory
      final File localFile = await imageFile.copy(localPath);

      print('✅ Image saved locally: $localPath');
      return DataSuccess(localFile.path);
    } catch (e) {
      print('❌ Local image save failed: $e');
      return DataError(ImageException(message: 'Failed to save image locally: $e'));
    }
  }
  
}