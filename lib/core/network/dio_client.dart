import 'package:dio/dio.dart';

Dio createDio() {
  final options = BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 8),
    responseType: ResponseType.json,
  );
  final dio = Dio(options);
  return dio;
}
