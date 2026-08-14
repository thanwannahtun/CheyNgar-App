part of 'user_profile_cubit.dart';

class UserProfileState extends Equatable {
  final BlocStatus status;
  final BlocStatus crudStatus;
  final User? user;
  final String? message;

  const UserProfileState({
    this.status = BlocStatus.initial,
    this.crudStatus = BlocStatus.initial,
    this.user,
    this.message,
  });

  UserProfileState copyWith({
    BlocStatus? status,
    BlocStatus? crudStatus,
    User? user,
    String? message,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      crudStatus: crudStatus ?? this.crudStatus,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, crudStatus, user, message];
}
