import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/api_utils/api_error_handler.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../models/user.dart';
import '../../repositories/auth_repo.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final AuthRepo _usersRepo;
  UserProfileCubit(this._usersRepo) : super(UserProfileState());

  Future<void> fetchUserProfile() async {
    try {
      emit(state.copyWith(status: BlocStatus.loading));
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay

      final user = await _usersRepo.getProfile();

      emit(state.copyWith(status: BlocStatus.success, user: user));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  resetState() {
    emit(UserProfileState());
  }

  Future<void> updateUserProfile(User updated) async {}
}
