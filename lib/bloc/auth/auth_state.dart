part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final BlocStatus status;
  final BlocStatus registerStatus;
  final BlocStatus changePinStatus;
  final User? currentUser;
  final String? message;

  const AuthState({
    this.status = BlocStatus.initial,
    this.registerStatus = BlocStatus.initial,
    this.changePinStatus = BlocStatus.initial,
    this.currentUser,
    this.message,
  });

  AuthState copyWith({
    BlocStatus? status,
    BlocStatus? registerStatus,
    BlocStatus? changePinStatus,
    User? currentUser,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      registerStatus: registerStatus ?? this.registerStatus,
      changePinStatus: changePinStatus ?? this.changePinStatus,
      currentUser: currentUser ?? this.currentUser,
      message: message ?? this.message,
    );
  }

  bool get isAuthenticated =>
      status == BlocStatus.success && currentUser != null;

  @override
  List<Object?> get props => [status, registerStatus, changePinStatus, currentUser, message];
}
