import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikesModel extends LikesEntity {
  const LikesModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.username,
    required super.timestamp,
  }); 

  factory LikesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; 

    return LikesModel(
      id: doc.id, 
      userId: data['userId'] as String,
      username: data['username'] as String,
      postId: data['postId'] as String,
      timestamp: _convertToDateTime(data['timestamp']),

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
      'postId': postId,
      'userId': userId,
      'username': username,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}