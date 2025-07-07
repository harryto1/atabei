import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class GetPostsByAuthorUseCase implements UseCase<DataState<List<PostEntity>>, GetPostsByAuthorParams> {
  final PostRepository _postRepository;

  GetPostsByAuthorUseCase(this._postRepository);

  @override
  Future<DataState<List<PostEntity>>> call({GetPostsByAuthorParams? params}) {
    if (params == null) {
      throw ArgumentError('GetPostsByAuthorParams cannot be null');
    }

    return _postRepository.getPostsFromAuthor(
      authorId: params.authorId,
      limit: params.limit,
    );
  }
}

class GetPostsByAuthorParams {
  final String authorId;
  final int limit;

  GetPostsByAuthorParams({
    required this.authorId,
    this.limit = 20,
  });
}