import 'dart:io';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:atabei/features/timeline/domain/repositories/local_image_repository.dart';

class DeletePostUseCase implements UseCase<DataState<void>, DeletePostParams> {
  final PostRepository _postRepository;
  final LocalImageRepository _localImageRepository;

  DeletePostUseCase(this._postRepository, this._localImageRepository);

  @override
  Future<DataState<void>> call({DeletePostParams? params}) async {
    if (params == null) {
      throw ArgumentError('DeletePostParams cannot be null');
    }

    final deleteResult = await _postRepository.deletePost(params.postId);
    
    if (deleteResult is DataError) {
      return deleteResult;
    }

    if (params.imageFile != null) {
      final imageDeleteResult = await _localImageRepository.deletePostImage(
        params.imageFile!.path,
      );
      
      if (imageDeleteResult is DataError) {
        print('❌ Failed to delete local image: ${imageDeleteResult.error?.message}');
      }
    }

    return const DataSuccess(null);
  }
}

class DeletePostParams {
  final String postId;
  final File? imageFile;

  DeletePostParams({
    required this.postId,
    this.imageFile,
  });
}