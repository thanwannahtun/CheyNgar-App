import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../ui/screens/auth/login_screen.dart';

import '../../data/share_preference.dart';
import '../../main.dart';

class LogoutInterceptor extends Interceptor {
  const LogoutInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    /// interceptor for Logging out the user when another user is logging with the same credentials
    debugPrint('Unauthorized  : ${err.response?.statusCode}');
    debugPrint('Message       : ${err.message}');
    if (err.response?.statusCode == 401) {
      _logoutUserAndDeleteCredential();
    }
    handler.next(err);
  }
}

_logoutUserAndDeleteCredential() async {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (route) => false,
  );
  await SharePreference.instance.clearAll();
}
