import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class GetPostsByAuthorStreamUseCase implements StreamUseCase<DataState<List<PostEntity>>, GetPostsByAuthorStreamParams> {
  final PostRepository _postRepository;

  GetPostsByAuthorStreamUseCase(this._postRepository);

  @override
  Stream<DataState<List<PostEntity>>> call({GetPostsByAuthorStreamParams? params}) {
    if (params == null) {
      throw ArgumentError('GetPostsByAuthorStreamParams cannot be null');
    }

    return _postRepository.getPostsByAuthorStream(
      params.authorId,
      limit: params.limit,
    );
  }
}

class GetPostsByAuthorStreamParams {
  final String authorId;
  final int limit;

  GetPostsByAuthorStreamParams({
    required this.authorId,
    this.limit = 20,
  });
}