import 'package:dio/dio.dart'; 

abstract class DataState<T> {
  final T? data; 

  final DioException? error; 

  const DataState({this.data, this.error});

}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
} 

class DataError<T> extends DataState<T> {
  const DataError(DioException error) : super(error: error);
}

class AuthException<T> extends DioException {
  AuthException({required String super.message, super.stackTrace})
      : super(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.unknown,
        );

  @override
  DioExceptionType get type => DioExceptionType.unknown;
}