import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId; 
  final String username; 
  final String? pathToProfilePicture; 
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
    required this.dateOfPost,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.bookmarks,
    required this.content
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        pathToProfilePicture,
        dateOfPost,
        likes,
        comments,
        reposts,
        bookmarks,
      ];
}