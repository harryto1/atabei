import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/timeline/data/models/post_model.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore; 
  static const String _postsCollection = 'post';

  PostRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DataState<PostEntity>> createPost(PostEntity post) async {
    try {
      // Convert PostEntity to PostModel for Firestore
      final postModel = PostModel(
        id: '', // Will be set by Firestore
        userId: post.userId,
        username: post.username,
        content: post.content,
        pathToProfilePicture: post.pathToProfilePicture,
        dateOfPost: post.dateOfPost,
        likes: post.likes,
        comments: post.comments,
        reposts: post.reposts,
        bookmarks: post.bookmarks,
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection(_postsCollection)
          .add(postModel.toFirestore());
      
      // Get the created document to return with the generated ID
      final createdDoc = await docRef.get();
      final createdPost = PostModel.fromFirestore(createdDoc) as PostEntity;
      
      return DataSuccess<PostEntity>(createdPost);
    } on FirebaseException catch (e) {
      return DataError(FirestoreException.fromFirebaseException(e));
    } catch (e) {
      return DataError(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<DataState> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<DataState<List<PostEntity>>> fetchPosts() {
    // TODO: implement fetchPosts
    throw UnimplementedError();
  }

  @override
  Stream<DataState<PostEntity>> getPostStream(String postId) {
    try {
      return _firestore
          .collection(_postsCollection)
          .doc(postId)
          .snapshots()
          .map<DataState<PostEntity>>((docSnapshot) {
        try {
          if (!docSnapshot.exists) {
            return DataError(FirestoreException(message: 'Post not found'));
          }
          final post = PostModel.fromFirestore(docSnapshot) as PostEntity;
          return DataSuccess<PostEntity>(post);
        } catch (e) {
          return DataError(FirestoreException(message: e.toString()));
        }
      }).handleError((error) {
        if (error is FirebaseException) {
          return DataError(FirestoreException.fromFirebaseException(error));
        }
        return DataError(FirestoreException(message: error.toString()));
      });
    } catch (e) {
      return Stream.value(DataError(FirestoreException(message: e.toString())));
    }
  }

  @override
  Stream<DataState<List<PostEntity>>> getPostsByAuthorStream(String authorId, {int limit = 20}) {
    try {
      return _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map<DataState<List<PostEntity>>>((querySnapshot) {
        try {
          final posts = querySnapshot.docs.map((doc) => PostModel.fromFirestore(doc) as PostEntity).toList();
          return DataSuccess<List<PostEntity>>(posts);
        } catch (e) {
          return DataError(FirestoreException(message: e.toString()));
        }
      }).handleError((error) {
        if (error is FirebaseException) {
          return DataError(FirestoreException.fromFirebaseException(error));
        }
        return DataError(FirestoreException(message: error.toString()));
      });
    } catch (e) {
      return Stream.value(DataError(FirestoreException(message: e.toString())));
    }
  }

  @override
  Stream<DataState<List<PostEntity>>> getPostsStream({int limit = 20}) {
    try { 
      return _firestore
          .collection(_postsCollection)
          .orderBy('dateOfPost', descending: true)
          .limit(limit)
          .snapshots()
          .map<DataState<List<PostEntity>>>((querySnapshot) {
            try {
              final posts = querySnapshot.docs
                .map((doc) => PostModel.fromFirestore(doc) as PostEntity)
                .toList();
              return DataSuccess<List<PostEntity>>(posts);
            } catch (e) {
              return DataError(FirestoreException(
                message: e.toString(),
              ));
            }
          }).handleError((error) {
            if (error is FirebaseException) {
              return DataError(FirestoreException.fromFirebaseException(error));
            } else {
              return DataError(FirestoreException(
                message: error.toString(),
              ));
            }
          });
    } catch (e) {
      return Stream.value(DataError(FirestoreException(
        message: e.toString(),
      )));
    }
  }
  
  @override
  likePost(String postId, String userId) {
    // TODO: implement likePost
    throw UnimplementedError();
  }
  
  @override
  unlikePost(String postId, String userId) {
    // TODO: implement unlikePost
    throw UnimplementedError();
  }
  
  @override
  Future<DataState<List<PostEntity>>> getPosts({int limit = 20}) async {
  try {
    final querySnapshot = await _firestore
        .collection(_postsCollection)
        .orderBy('dateOfPost', descending: true)
        .limit(limit)
        .get(); // Use .get() instead of .snapshots() for one-time fetch

    final posts = querySnapshot.docs
        .map((doc) => PostModel.fromFirestore(doc) as PostEntity)
        .toList();
    
    return DataSuccess<List<PostEntity>>(posts);
  } on FirebaseException catch (e) {
    return DataError(FirestoreException.fromFirebaseException(e));
  } catch (e) {
    return DataError(FirestoreException(message: e.toString()));
  }
}
}