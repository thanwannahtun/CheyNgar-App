import 'package:flutter/material.dart';

import '../core/api_utils/api_service.dart';
import '../core/env.dart';
import '../data/share_preference.dart';
import '../models/user.dart';

class AuthRepo extends ApiService {
  AuthRepo();

  /// register
  Future<User> register(String pinCode, String phoneNumber) async {
    try {
      final response = await postRequest('/users/register', {
        'pinCode': pinCode,
        'phoneNumber': phoneNumber.trim(),
      });
      if (response.statusCode == 201) {
        return User.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<User> login(String pinCode, String phoneNumber) async {
    try {
      try {
        final response = await postRequest('/users/login', {
          'pinCode': pinCode,
          'phoneNumber': phoneNumber,
        });
        if (response.statusCode == 200) {
          final token = response.data["data"]["accessToken"];
          await SharePreference.instance.setString(Env.accessToken, token);
          debugPrint("token: $token");
          return User.fromJson(response.data["data"]["user"]);
        }
        throw Exception("Invalid Response!");
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
