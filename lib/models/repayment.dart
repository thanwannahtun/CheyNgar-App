// -- 3. Repayments: Tracking partial or full payments
// CREATE TABLE Repayments (
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// transaction_id INTEGER,
// amount_paid DECIMAL(18, 2) NOT NULL,
// payment_date DATE DEFAULT CURRENT_DATE,
// payment_type TEXT, -- INTEREST_ONLY, PRINCIPAL_ONLY, BOTH
// note TEXT,
// FOREIGN KEY (transaction_id) REFERENCES Transactions(id)
// );

import 'package:chey_ngar/models/transactions.dart';
import 'package:equatable/equatable.dart';

enum PaymentType {
  interestOnly('INTEREST_ONLY'),
  principalOnly('PRINCIPAL_ONLY'),
  both('BOTH');

  final String value;

  const PaymentType(this.value);

  PaymentType fromString(String str) {
    return PaymentType.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => PaymentType.both,
    );
  }
}

class Repayment extends Equatable {
  final int? id;
  final int? transactionId;
  final double? amountPaid;
  final String? note;
  final DateTime? paymentDate;
  final PaymentType? paymentType;
  final Transaction? transaction;

  const Repayment({
    this.paymentType,
    this.id,
    this.transactionId,
    this.note,
    this.amountPaid,
    this.paymentDate,
    this.transaction,
  });

  Repayment copyWith({
    int? id,
    int? transactionId,
    DateTime? paymentDate,
    String? note,
    double? amountPaid,
    PaymentType? paymentType,
    Transaction? transaction,
  }) => Repayment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    paymentDate: paymentDate ?? this.paymentDate,
    note: note ?? this.note,
    amountPaid: amountPaid ?? this.amountPaid,
    paymentType: paymentType ?? this.paymentType,
    transaction: transaction ?? this.transaction,
  );

  factory Repayment.fromJson(Map<String, dynamic> json) => Repayment(
    id: json['id'],
    transactionId: json['transactionId'],
    paymentDate: json['paymentDate'] != null
        ? DateTime.parse(json['paymentDate'])
        : null,
    amountPaid: json['amountPaid'] != null
        ? double.parse(json['amountPaid'].toString())
        : null,
    note: json['note'],
    paymentType: json['paymentType'] != null
        ? PaymentType.values.firstWhere(
            (e) => e.value == json['paymentType'],
            orElse: () => PaymentType.both,
          )
        : null,
    transaction: json['transaction'] != null
        ? Transaction.fromJson(json['transaction'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'paymentDate': paymentDate?.toIso8601String(),
    'note': note,
    'amountPaid': amountPaid,
    'paymentType': paymentType?.value,
  };

  @override
  List<Object?> get props => [
    id,
    transactionId,
    paymentDate,
    note,
    amountPaid,
    paymentType,
    transaction,
  ];

  @override
  String toString() {
    return 'Repayment(id: $id, transactionId: $transactionId, paymentDate: $paymentDate, note: $note, amountPaid: $amountPaid, paymentType: $paymentType, transaction: $transaction)';
  }
}
