import 'package:flutter/material.dart';

import '../core/api_utils/api_service.dart';
import '../core/env.dart';
import '../data/share_preference.dart';
import '../models/user.dart';

class AuthRepo extends ApiService {
  AuthRepo();

  /// register
  Future<User> register(String name, String pinCode, String phoneNumber) async {
    try {
      final response = await postRequest('/users/register', {
        'pinCode': pinCode,
        'name': name,
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

  Future<void> logout() async {
    try {
      await SharePreference.instance.remove(Env.accessToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    // Clear all local secure storage (tokens, terms acceptance, etc.)
    final response = await postRequest('/app/auth/delete_account', {});
    if (response.statusCode == 200) {
      await SharePreference.instance.clearAll();
    } else {
      throw Exception(response.data['message'] ?? 'Account Deletion failed');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await getRequest('/users/profile');
      if (response.statusCode == 200) {
        return User.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      final response = await postRequest('/users/change-pin', {
        'currentPin': currentPin.trim(),
        'newPin': newPin.trim(),
      });
      if (response.statusCode == 200) {
        return;
      }
      throw Exception(
        response.data['message'] ?? 'PIN ပြောင်းလဲရာတွင် အမှားဖြစ်ပွားခဲ့သည်',
      );
    } catch (e) {
      rethrow;
    }
  }
}
