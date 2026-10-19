import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final int baseRetryIntervalMs;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseRetryIntervalMs = 2000, // Starts at 2 seconds
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Read current retry count (default to 0 if null)
    final currentRetry = err.requestOptions.extra['retries'] ?? 0;

    // 1. FIX: Changed '!=' to '<' to guarantee it stops after maxRetries [1]
    if (_shouldRetry(err) && currentRetry < maxRetries) {
      // Increment the retry counter explicitly
      final nextRetry = currentRetry + 1;
      err.requestOptions.extra['retries'] = nextRetry;

      // 2. Exponential Backoff: Wait longer each time (e.g., 2s -> 4s -> 8s)
      // This gives Render time to wake up without wasting retries immediately
      final delayDuration = Duration(
        milliseconds: (baseRetryIntervalMs * nextRetry).toInt(),
      );
      await Future.delayed(delayDuration);

      try {
        // Attempt to re-fetch the exact same request
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        // Pass the error downward so the next interceptor iteration can handle it
        return handler.next(retryError);
      }
    }

    // Forward the error if we run out of retries or shouldn't retry
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        // Only retry bad status codes if they are standard Gateway timeouts
        (err.type == DioExceptionType.badResponse &&
            (err.response?.statusCode == 502 ||
                err.response?.statusCode == 503 ||
                err.response?.statusCode == 504));
  }
}
