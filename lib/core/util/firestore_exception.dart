import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreException extends DioException {
  FirestoreException({
    required String super.message,
    super.stackTrace,
  }) : super(
          requestOptions: RequestOptions(path: ''),
        );

  factory FirestoreException.fromFirebaseException(FirebaseException e) {
    return FirestoreException(
      message: e.message ?? 'An unknown Firebase error occurred',
      stackTrace: e.stackTrace,
    );
  }
}