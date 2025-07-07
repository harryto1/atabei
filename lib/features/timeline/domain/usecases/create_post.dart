import 'dart:io';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:atabei/features/timeline/domain/repositories/local_image_repository.dart';
import 'package:dio/dio.dart';

class CreatePostUseCase implements UseCase<DataState<PostEntity>, CreatePostParams> {
  final PostRepository _postRepository;
  final LocalImageRepository _localImageRepository;

  CreatePostUseCase(this._postRepository, this._localImageRepository);

  @override
  Future<DataState<PostEntity>> call({CreatePostParams? params}) async {
    if (params == null) {
      throw ArgumentError('CreatePostParams cannot be null');
    }

    var post = params.post;

    if (params.imageFile != null) {
      final imageResult = await _localImageRepository.uploadPostImage(
        params.imageFile!,
        params.post.id,
      );
      
      if (imageResult is DataSuccess) {
        post = post.copyWith(pathToImage: imageResult.data);
      } else if (imageResult is DataError) {
        return DataError(imageResult.error!);
      }
    }

    final postResult = await _postRepository.createPost(post);

    if (postResult is DataSuccess) {
      return DataSuccess(postResult.data);
    } else {
      return DataError(FirestoreException(message: postResult.error?.message ?? "Unknown error") as DioException);
    }
  }
  }


class CreatePostParams {
  final PostEntity post;
  final File? imageFile;

  CreatePostParams({
    required this.post,
    this.imageFile,
  });
}