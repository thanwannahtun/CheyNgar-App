part of 'transactions_cubit.dart';

class TransactionsState extends Equatable {
  final BlocStatus? status;
  final BlocStatus? crudStatus;
  final List<Transaction>? transactions;
  final List<Transaction>? filtedTransactions;
  final TransactionDirection? direction;
  final String? message;

  const TransactionsState({
    this.status,
    this.crudStatus,
    this.transactions,
    this.filtedTransactions,
    this.direction,
    this.message,
  });

  const TransactionsState.init()
    : status = BlocStatus.initial,
      crudStatus = null,
      transactions = null,
      filtedTransactions = null,
      direction = null,
      message = null;

  TransactionsState copyWith({
    BlocStatus? status,
    BlocStatus? crudStatus,
    List<Transaction>? transactions,
    List<Transaction>? filtedTransactions,
    TransactionDirection? direction,
    String? message,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      crudStatus: crudStatus ?? this.crudStatus,
      transactions: transactions ?? this.transactions,
      filtedTransactions: filtedTransactions ?? this.filtedTransactions,
      direction: direction ?? this.direction,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    crudStatus,
    transactions,
    direction,
    message,
    filtedTransactions,
  ];
}
