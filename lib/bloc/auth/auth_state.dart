part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final BlocStatus status;
  final BlocStatus registerStatus;
  final User? currentUser;
  final String? message;

  const AuthState({
    this.status = BlocStatus.initial,
    this.registerStatus = BlocStatus.initial,
    this.currentUser,
    this.message,
  });

  AuthState copyWith({
    BlocStatus? status,
    BlocStatus? registerStatus,
    User? currentUser,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      registerStatus: registerStatus ?? this.registerStatus,
      currentUser: currentUser ?? this.currentUser,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, registerStatus, currentUser, message];
}
