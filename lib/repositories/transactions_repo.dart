import 'package:chey_ngar/models/repayment.dart';

import '../core/api_utils/api_service.dart';
import '../models/transactions.dart';

class TransactionsRepo extends ApiService {
  TransactionsRepo();

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await postRequest('/transactions', transaction.toJson());
      if (response.statusCode == 201) {
        return Transaction.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Transaction> fetchTransactionDetail(int transactionId) async {
    try {
      final response = await getRequest('/transactions/$transactionId');
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Transaction>> fetchTransactionsHistory({
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await getRequest(
        '/transactions',
        queryParameters: query,
      );
      if (response.statusCode == 200) {
        return (response.data["data"] as List)
            .map((e) => Transaction.fromJson(e))
            .toList();
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Transaction> updateTransactionStatus(
    int transactionId, {
    required String status,
    String? closureReason,
  }) async {
    try {
      final response = await patchRequest(
        '/transactions/$transactionId/status',
        {
          'status': status,
          if (closureReason != null && closureReason.isNotEmpty)
            'closureReason': closureReason,
        },
      );
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Repayment> createRepayment(Repayment payment) async {
    try {
      final response = await postRequest('/repayments', payment.toJson());
      if (response.statusCode == 201) {
        return Repayment.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }
}
