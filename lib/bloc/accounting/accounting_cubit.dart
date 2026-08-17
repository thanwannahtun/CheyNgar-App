import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_utils/api_error_handler.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../models/accounting_entry.dart';
import '../../repositories/accounting_repo.dart';
import 'accounting_state.dart';

class AccountingCubit extends Cubit<AccountingState> {
  final AccountingRepo _repo;

  AccountingCubit(this._repo) : super(const AccountingState.init());

  Future<void> loadAccountingData({JournalEntryType? filter}) async {
    try {
      emit(state.copyWith(
        status: BlocStatus.loading,
        selectedFilter: filter,
        clearFilter: filter == null,
      ));

      final summaryFuture = _repo.fetchFinancialSummary();
      final entriesFuture = _repo.fetchJournalEntries(
        entryType: filter?.value,
      );

      final results = await Future.wait([summaryFuture, entriesFuture]);

      emit(state.copyWith(
        status: BlocStatus.success,
        summary: results[0] as FinancialSummary,
        entries: results[1] as List<JournalEntry>,
        selectedFilter: filter,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        message: handleErrorMessage(e),
      ));
    }
  }

  Future<void> filterEntries(JournalEntryType? filter) async {
    try {
      emit(state.copyWith(
        selectedFilter: filter,
        clearFilter: filter == null,
      ));

      final entries = await _repo.fetchJournalEntries(
        entryType: filter?.value,
      );

      emit(state.copyWith(
        entries: entries,
        selectedFilter: filter,
      ));
    } catch (e) {
      emit(state.copyWith(
        message: handleErrorMessage(e),
      ));
    }
  }
}
