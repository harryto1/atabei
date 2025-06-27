import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final int userId; 
  final String username; 
  final String? pathToProfilePicture; 
  final DateTime dateOfPost; 
  final DateTime timeOfPost; 
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
    required this.timeOfPost,
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
        timeOfPost,
        likes,
        comments,
        reposts,
        bookmarks,
      ];
}