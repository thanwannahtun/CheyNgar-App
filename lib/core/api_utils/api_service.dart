import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'base_url_interceptor.dart';
import 'logging_inteceptor.dart';
import 'logout_interceptor.dart';
import 'retry_intercepton.dart';
import 'token_interceptor.dart';

class ApiService {
  final Dio _dio;

  ApiService([baseUrl])
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60), //Render's cold start
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          receiveDataWhenStatusError: true,
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    _dio.interceptors.add(const BaseUrlInterceptor());
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    _dio.interceptors.add(LoggingInterceptor());

    _dio.interceptors.add(const LogoutInterceptor());
    _dio.interceptors.add(TokenInterceptor());
  }

  Future<Response> getRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters, data: body);
  }

  Future<Response> postRequest(
    String path,
    Object? data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // return await _dio.post(path, data: data);
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      // options: Options(
      //   contentType: Headers.multipartFormDataContentType,
      // ),
    );
  }

  Future<Response> putRequest(String path, Map<String, dynamic> data) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> deleteRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  Future<Response> patchRequest(String path, Map<String, dynamic> data) async {
    return await _dio.patch(path, data: data);
  }
}
