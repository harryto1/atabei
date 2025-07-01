import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    super.pathToProfilePicture,
    super.pathToImage, 
    required super.dateOfPost,
    required super.likes,
    required super.comments,
    required super.reposts,
    required super.bookmarks,
    required super.content, 
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; 

    return PostModel(
      id: doc.id, // Firestore document ID is already a String
      userId: data['userId'] as String,
      username: data['username'] as String,
      pathToProfilePicture: data['pathToProfilePicture'] as String?,
      pathToImage: data['pathToImage'] as String?, 
      dateOfPost: _convertToDateTime(data['dateOfPost']),
      likes: data['likes'] as int? ?? 0,
      comments: data['comments'] as int? ?? 0,
      reposts: data['reposts'] as int? ?? 0,
      bookmarks: data['bookmarks'] as int? ?? 0,
      content: data['content'] as String? ?? '', 
    );
  }

  // Helper method to convert various date formats to DateTime
  static DateTime _convertToDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      // Note: We don't include 'id' here since Firestore handles document IDs separately
      'userId': userId,
      'username': username,
      'pathToProfilePicture': pathToProfilePicture,
      'pathToImage': pathToImage,
      'dateOfPost': Timestamp.fromDate(dateOfPost),
      'likes': likes,
      'comments': comments,
      'reposts': reposts,
      'bookmarks': bookmarks,
      'content': content, 
    };
  }

  @override
  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? pathToProfilePicture,
    String? pathToImage,
    DateTime? dateOfPost,
    int? likes,
    int? comments,
    int? reposts,
    int? bookmarks,
    String? content,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      pathToProfilePicture: pathToProfilePicture ?? this.pathToProfilePicture,
      pathToImage: pathToImage ?? this.pathToImage,
      dateOfPost: dateOfPost ?? this.dateOfPost,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      bookmarks: bookmarks ?? this.bookmarks,
      content: content ?? this.content,
    );
  }
}