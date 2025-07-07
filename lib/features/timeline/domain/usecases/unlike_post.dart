import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class UnlikePostUseCase implements UseCase<DataState<void>, UnlikePostParams> {
  final PostRepository _postRepository;

  UnlikePostUseCase(this._postRepository);

  @override
  Future<DataState<void>> call({UnlikePostParams? params}) {
    if (params == null) {
      throw ArgumentError('UnlikePostParams cannot be null');
    }
    
    return _postRepository.unlikePost(
      params.postId,
      params.userId,
    );
  }
}

class UnlikePostParams {
  final String postId;
  final String userId;

  UnlikePostParams({
    required this.postId,
    required this.userId,
  });
}