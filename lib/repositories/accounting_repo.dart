import '../core/api_utils/api_service.dart';
import '../models/accounting_entry.dart';

class AccountingRepo extends ApiService {
  AccountingRepo();

  Future<FinancialSummary> fetchFinancialSummary() async {
    try {
      final response = await getRequest('/accounting/summary');
      if (response.statusCode == 200) {
        return FinancialSummary.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JournalEntry>> fetchJournalEntries({
    String? entryType,
    int page = 1,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        if (entryType != null && entryType.isNotEmpty) 'entryType': entryType,
      };

      final response = await getRequest(
        '/accounting/ledger',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        return (response.data["data"] as List)
            .map((e) => JournalEntry.fromJson(e))
            .toList();
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }
}
