import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chey_ngar/core/api_utils/api_error_handler.dart';
import 'package:chey_ngar/core/bloc_utils/bloc_status.dart';
import '../../models/repayment.dart';
import '../../models/transactions.dart';
import '../../repositories/transactions_repo.dart';

part 'transactions_detail_state.dart';

class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  final TransactionsRepo _transactionsRepo;
  TransactionDetailCubit(this._transactionsRepo)
    : super(const TransactionDetailState.init());

  Future<void> fetchTransactionDetail(int transactionId) async {
    try {
      emit(state.copyWith(status: BlocStatus.loading));
      // await Future.delayed(Duration(seconds: 2));
      final transaction = await _transactionsRepo.fetchTransactionDetail(
        transactionId,
      );
      emit(
        state.copyWith(status: BlocStatus.success, transaction: transaction),
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

  Future<void> createRepayment(Repayment repayment) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      final created = await _transactionsRepo.createRepayment(repayment);
      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          repayment: created,
          // append the new repayment to the existing repayments list in state's transaction
          transaction: state.transaction?.copyWith(
            repayments: [...?state.transaction?.repayments, created],
          ),
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
