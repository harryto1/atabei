import 'package:equatable/equatable.dart';

class LikesEntity extends Equatable {
  final String id; 
  final String postId; 
  final String userId;
  final String username; 
  final DateTime timestamp;

  const LikesEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [postId, userId, username, timestamp];
}