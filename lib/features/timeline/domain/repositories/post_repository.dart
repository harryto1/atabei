import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';

abstract class PostRepository {
  /// Fetches posts from the repository.
  ///
  /// Returns a list of posts.
  Future<DataState<List<PostEntity>>> fetchPosts();

  /// Creates a new post in the repository.
  ///
  /// [post] is the post to be created.
  Future<DataState> createPost(PostEntity post);

  /// Deletes a post from the repository.
  ///
  /// [postId] is the ID of the post to be deleted.
  Future<DataState> deletePost(String postId);

  Stream<DataState<List<PostEntity>>> getPostsStream({int limit = 20});
  Stream<DataState<PostEntity>> getPostStream(String postId);
  Stream<DataState<List<PostEntity>>> getPostsByAuthorStream(String authorId, {int limit = 20});

  Future<DataState<List<PostEntity>>> getPostsFromAuthor({
    required String authorId,
    int limit = 20,
  });

  likePost(String postId, String userId, String username) {}

  unlikePost(String postId, String userId) {}

  Future<DataState<List<PostEntity>>> getPosts({int limit = 20});


}