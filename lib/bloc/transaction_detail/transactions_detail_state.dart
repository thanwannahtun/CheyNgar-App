part of 'transaction_detail_cubit.dart';

class TransactionDetailState extends Equatable {
  final BlocStatus? status; // detail status
  final BlocStatus? crudStatus; // repayment status
  final BlocStatus? statusChangeStatus; // status change status
  final Transaction? transaction;
  final Repayment? repayment;
  final String? message;

  const TransactionDetailState({
    this.status,
    this.crudStatus,
    this.statusChangeStatus,
    this.transaction,
    this.repayment,
    this.message,
  });

  const TransactionDetailState.init()
    : status = BlocStatus.initial,
      crudStatus = null,
      statusChangeStatus = null,
      transaction = null,
      repayment = null,
      message = null;

  TransactionDetailState copyWith({
    BlocStatus? status,
    BlocStatus? crudStatus,
    BlocStatus? statusChangeStatus,
    Transaction? transaction,
    Repayment? repayment,
    String? message,
  }) {
    return TransactionDetailState(
      status: status ?? this.status,
      crudStatus: crudStatus ?? this.crudStatus,
      statusChangeStatus: statusChangeStatus ?? this.statusChangeStatus,
      transaction: transaction ?? this.transaction,
      repayment: repayment ?? this.repayment,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    crudStatus,
    statusChangeStatus,
    transaction,
    message,
    repayment,
  ];
}
