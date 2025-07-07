import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';

class GetPostsUseCase implements UseCase<DataState<List<PostEntity>>, GetPostsParams> {
  final PostRepository _postRepository;

  GetPostsUseCase(this._postRepository);
  
  @override
  Future<DataState<List<PostEntity>>> call({GetPostsParams? params}) {
    return _postRepository.getPosts(
      limit: params?.limit ?? 20,
    );
  }

}

class GetPostsParams {
  final int limit; 

  GetPostsParams({this.limit = 20});
}