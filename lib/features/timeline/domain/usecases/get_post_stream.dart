import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class GetPostStreamUseCase implements StreamUseCase<DataState<PostEntity>, GetPostStreamParams> {
  final PostRepository _postRepository;

  GetPostStreamUseCase(this._postRepository);

  @override
  Stream<DataState<PostEntity>> call({GetPostStreamParams? params}) {
    if (params == null) {
      throw ArgumentError('GetPostStreamParams cannot be null');
    }
    
    return _postRepository.getPostStream(params.postId);
  }
}

class GetPostStreamParams {
  final String postId;

  GetPostStreamParams({required this.postId});
}