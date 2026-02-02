import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chey_ngar/core/api_utils/api_error_handler.dart';
import 'package:chey_ngar/core/bloc_utils/bloc_status.dart';
import '../../models/transactions.dart';
import '../../repositories/transactions_repo.dart';

part 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepo _contactsRepo;
  TransactionsCubit(this._contactsRepo) : super(const TransactionsState.init());

  Transaction? currentQuery;

  Future<void> fetchTransactions({Transaction? query}) async {
    try {
      emit(state.copyWith(status: BlocStatus.loading));
      final transactions = await _contactsRepo.fetchTransactionsHistory(
        query: query?.toJson(),
      );
      currentQuery = query;
      emit(
        state.copyWith(
          status: BlocStatus.success,
          transactions: transactions,
          filtedTransactions: transactions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  reloadLastQuery() {
    fetchTransactions(query: currentQuery);
  }

  // void filterByReferenceNo(String name) {
  //   final filtered = (state.transaction ?? [])
  //       .where((r) => (r.referenceNo ?? "").toUpperCase().contains(name.toUpperCase()))
  //       .toList();
  //   emit(state.copyWith(filtedTransactions: filtered));
  // }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      final created = await _contactsRepo.createTransaction(transaction);
      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          transactions: [...state.transactions ?? [], created],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          crudStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }
}
