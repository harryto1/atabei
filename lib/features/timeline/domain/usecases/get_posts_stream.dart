import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class GetPostsStreamUseCase implements StreamUseCase<DataState<List<PostEntity>>, GetPostsStreamUseCaseParams> {
  final PostRepository _postRepository;

  GetPostsStreamUseCase(this._postRepository);

  @override
  Stream<DataState<List<PostEntity>>> call({GetPostsStreamUseCaseParams? params}) {
    return _postRepository.getPostsStream(
      limit: params?.limit ?? 20,
    ); 
  }
}

class GetPostsStreamUseCaseParams {
  final int limit;

  GetPostsStreamUseCaseParams({this.limit = 20});
}