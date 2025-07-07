import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class LikePostUseCase implements UseCase<DataState<void>, LikePostParams> {
  final PostRepository _postRepository;

  LikePostUseCase(this._postRepository);

  @override
  Future<DataState<void>> call({LikePostParams? params}) {
    if (params == null) {
      throw ArgumentError('LikePostParams cannot be null');
    }
    
    return _postRepository.likePost(
      params.postId,
      params.userId,
      params.username,
    );
  }
}

class LikePostParams {
  final String postId;
  final String userId;
  final String username;

  LikePostParams({
    required this.postId,
    required this.userId,
    required this.username,
  });
}