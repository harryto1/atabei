import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/dependencies.dart';
import 'package:atabei/features/timeline/data/models/post_model.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore; 
  static const String _postsCollection = 'post';

  PostRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? sl<FirebaseFirestore>();

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
        pathToImage: post.pathToImage, 
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
  Future<DataState<void>> deletePost(String postId) async {
    try {
      // Delete the post document from Firestore
      await _firestore
          .collection(_postsCollection)
          .doc(postId)
          .delete();
      return DataSuccess<void>(null);
    } on FirebaseException catch (e) {
      return DataError(FirestoreException.fromFirebaseException(e));
    } catch (e) {
      return DataError(FirestoreException(message: e.toString()));
    }
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
          .orderBy('dateOfPost', descending: true)
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
  Future<DataState<List<PostEntity>>> getPostsFromAuthor({
    required String authorId,
    int limit = 20,
  }) async {
    try {
      print('📚 Fetching posts from author: $authorId (limit: $limit)');
      
      final querySnapshot = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: authorId)
          .orderBy('dateOfPost', descending: true)
          .limit(limit)
          .get();

      final posts = querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc) as PostEntity)
          .toList();
      
      print('📚 Found ${posts.length} posts from author: $authorId');
      
      return DataSuccess<List<PostEntity>>(posts);
    } on FirebaseException catch (e) {
      print('❌ Firebase error getting posts from author: ${e.message}');
      return DataError(FirestoreException.fromFirebaseException(e));
    } catch (e) {
      print('❌ Error getting posts from author: $e');
      return DataError(FirestoreException(message: e.toString()));
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
  likePost(String postId, String userId, String username) async {
    try {
      await _firestore.collection('likes').add({
        'postId': postId,
        'userId': userId,
        'username': username,
        'timestamp': FieldValue.serverTimestamp(),
      }); 

      await _firestore.collection(_postsCollection).doc(postId).update({
        'likes': FieldValue.increment(1), 
      });
      
      print('✅ Like added for post: $postId');
      return DataSuccess<void>(null);
    } catch (e) {
      print('❌ Failed to like post: $e');
      throw FirestoreException(message: 'Failed to like post: $e');
    }
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