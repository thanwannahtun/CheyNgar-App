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

  register(String pinCode, String phoneNumber) async {
    emit(state.copyWith(registerStatus: BlocStatus.loading));
    try {
      final user = await _authRepo.register(pinCode, phoneNumber);
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
}
