import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api_utils/api_error_handler.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../models/user.dart';
import '../../repositories/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(AuthState());

  final AuthRepo _authRepo;

  login(String pinCode, String phone) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final user = await _authRepo.login(pinCode, phone);
      emit(state.copyWith(status: BlocStatus.success, currentUser: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  logout() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _authRepo.logout();
      emit(state.copyWith(status: BlocStatus.success, currentUser: null));
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  register(String name, String pinCode, String phoneNumber) async {
    emit(state.copyWith(registerStatus: BlocStatus.loading));
    try {
      final user = await _authRepo.register(name, pinCode, phoneNumber);
      emit(
        state.copyWith(registerStatus: BlocStatus.success, currentUser: user),
      );
    } catch (e) {
      emit(
        state.copyWith(
          registerStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  getProfile() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final user = await _authRepo.getProfile();
      emit(state.copyWith(status: BlocStatus.success, currentUser: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Delete Account
  // ────────────────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _authRepo.deleteAccount();
      emit(const AuthState()); // back to guest/initial
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
      rethrow; // so DeleteAccountScreen can show the error
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Change PIN Code
  // ────────────────────────────────────────────────────────────────
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    emit(state.copyWith(changePinStatus: BlocStatus.loading));
    try {
      await _authRepo.changePin(currentPin: currentPin, newPin: newPin);
      emit(state.copyWith(changePinStatus: BlocStatus.success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          changePinStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
      return false;
    }
  }

  void resetChangePinStatus() {
    emit(state.copyWith(changePinStatus: BlocStatus.initial));
  }
}
