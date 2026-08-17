import 'package:equatable/equatable.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../models/accounting_entry.dart';

class AccountingState extends Equatable {
  final BlocStatus status;
  final FinancialSummary? summary;
  final List<JournalEntry> entries;
  final JournalEntryType? selectedFilter;
  final String? message;

  const AccountingState({
    required this.status,
    this.summary,
    this.entries = const [],
    this.selectedFilter,
    this.message,
  });

  const AccountingState.init()
    : status = BlocStatus.initial,
      summary = null,
      entries = const [],
      selectedFilter = null,
      message = null;

  AccountingState copyWith({
    BlocStatus? status,
    FinancialSummary? summary,
    List<JournalEntry>? entries,
    JournalEntryType? selectedFilter,
    bool clearFilter = false,
    String? message,
  }) {
    return AccountingState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      entries: entries ?? this.entries,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, summary, entries, selectedFilter, message];
}
