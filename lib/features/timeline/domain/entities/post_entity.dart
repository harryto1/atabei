import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId; 
  final String username; 
  final String? pathToProfilePicture; 
  final String? pathToImage; 
  final DateTime dateOfPost; 
  final int likes;
  final int comments;
  final int reposts;
  final int bookmarks;
  final String content; 

  const PostEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.pathToProfilePicture,
    this.pathToImage, 
    required this.dateOfPost,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.bookmarks,
    required this.content
  });

  PostEntity copyWith({
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
    String? content
  }) {
    return PostEntity(
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
      content: content ?? this.content
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        pathToProfilePicture,
        pathToImage, 
        dateOfPost,
        likes,
        comments,
        reposts,
        bookmarks,
      ];
}