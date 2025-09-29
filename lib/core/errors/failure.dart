import 'package:fpdart/fpdart.dart';

/// 通用失败类型（可扩展子类）
sealed class Failure {
  final String code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.code, this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'Failure($code, $message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super('network', message, cause: cause, stackTrace: stackTrace);
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure(String message, {this.statusCode, Object? cause, StackTrace? stackTrace})
      : super('api', message, cause: cause, stackTrace: stackTrace);
}

class ParseFailure extends Failure {
  const ParseFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super('parse', message, cause: cause, stackTrace: stackTrace);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super('unknown', message, cause: cause, stackTrace: stackTrace);
}

/// 常用别名
typedef TEither<T> = TaskEither<Failure, T>;
