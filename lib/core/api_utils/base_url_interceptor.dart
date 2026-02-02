import 'package:dio/dio.dart';

class BaseUrlInterceptor extends Interceptor {
  const BaseUrlInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// interceptor for adding baseurl in the request's base url
    options.baseUrl = "https://chey-ngar-backend.onrender.com/api/v1";
    // options.baseUrl = "http://localhost:3500/api/v1";
    // options.baseUrl = "http://192.168.99.122:3300/api/v1";
    return handler.next(options);
  }
}
