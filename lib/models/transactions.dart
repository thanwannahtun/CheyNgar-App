// CREATE TABLE Transactions (
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// contact_id INTEGER,
// direction TEXT CHECK(direction IN ('LEND', 'BORROW')), -- LEND (အကြွေးရှင်), BORROW (ချေးသူ)
// principal_amount DECIMAL(18, 2) NOT NULL,
// interest_rate DECIMAL(5, 2), -- Percentage (e.g., 5.00 for 5%)
// interest_type TEXT DEFAULT 'MONTHLY', -- DAILY, MONTHLY, FIXED
// start_date DATE DEFAULT CURRENT_DATE,
// due_date DATE,
// status TEXT DEFAULT 'OPEN', -- OPEN, SETTLED, OVERDUE
// remark TEXT,
// FOREIGN KEY (contact_id) REFERENCES Contacts(id)
// );

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'contact.dart';
import 'repayment.dart';

enum InterestType {
  daily('DAILY'),
  monthly('MONTHLY'),
  fixed('FIXED');

  final String value;

  const InterestType(this.value);

  static InterestType fromString(String str) {
    return InterestType.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => InterestType.monthly,
    );
  }
}

enum TransactionDirection {
  lend('LEND'), // အကြွေးရှင်
  borrow('BORROW'); // ချေးသူ

  final String value;

  const TransactionDirection(this.value);

  static TransactionDirection fromString(String str) {
    return TransactionDirection.values.firstWhere(
      (e) => e.value.toUpperCase() == str.toUpperCase(),
      orElse: () => TransactionDirection.lend,
    );
  }
}

enum TransactionStatus {
  open('OPEN', Colors.blue),
  settled('SETTLED', Colors.green),
  overdue('OVERDUE', Colors.red);

  final String value;
  final Color color;

  const TransactionStatus(this.value, this.color);

  static TransactionStatus fromString(String str) {
    return TransactionStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == str.toUpperCase(),
      orElse: () => TransactionStatus.open,
    );
  }
}

class Transaction extends Equatable {
  final int? id;
  final int? contactId;
  final double? initialPrincipal;
  final double? remainingPrincipal;
  final double? interestRate;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? lastInterestCalcDate;
  final String? remark;
  final TransactionDirection? direction;
  final TransactionStatus? status;
  final InterestType? interestType;
  final Contact? contact;
  final List<Repayment>? repayments;

  const Transaction({
    this.startDate,
    this.lastInterestCalcDate,
    this.dueDate,
    this.remark,
    this.direction,
    this.status,
    this.interestType,
    this.contact,
    this.id,
    this.contactId,
    this.interestRate,
    this.initialPrincipal,
    this.remainingPrincipal,
    this.repayments,
  });

  Transaction copyWith({
    int? id,
    int? contactId,
    double? interestRate,
    double? initialPrincipal,
    double? remainingPrincipal,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? lastInterestCalcDate,
    String? remark,
    TransactionDirection? direction,
    TransactionStatus? status,
    InterestType? interestType,
    Contact? contact,
    List<Repayment>? repayments,
  }) => Transaction(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    interestRate: interestRate ?? this.interestRate,
    initialPrincipal: initialPrincipal ?? this.initialPrincipal,
    remainingPrincipal: remainingPrincipal ?? this.remainingPrincipal,
    startDate: startDate ?? this.startDate,
    dueDate: dueDate ?? this.dueDate,
    lastInterestCalcDate: lastInterestCalcDate ?? this.lastInterestCalcDate,
    remark: remark ?? this.remark,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    interestType: interestType ?? this.interestType,
    contact: contact ?? this.contact,
    repayments: repayments ?? this.repayments,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    contactId: json['contactId'],
    initialPrincipal: double.parse(json['initialPrincipal'].toString()),
    remainingPrincipal: double.parse(json['remainingPrincipal'].toString()),
    interestRate: double.parse(json['interestRate'].toString()),
    status: json['status'] != null
        ? TransactionStatus.fromString(json['status'])
        : null,
    direction: json['direction'] != null
        ? TransactionDirection.fromString(json['direction'])
        : null,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    interestType: json['interestType'] != null
        ? InterestType.fromString(json['interestType'])
        : null,
    remark: json['remark'],
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null,
    lastInterestCalcDate: json['lastInterestCalcDate'] != null
        ? DateTime.parse(json['lastInterestCalcDate'])
        : null,
    contact: json['contact'] != null ? Contact.fromJson(json['contact']) : null,
    repayments: json['repayments'] != null
        ? (json['repayments'] as List)
              .map((e) => Repayment.fromJson(e))
              .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'contactId': contactId,
    'interestRate': interestRate,
    'initialPrincipal': initialPrincipal,
    'remainingPrincipal': remainingPrincipal,
    'startDate': startDate?.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'lastInterestCalcDate': lastInterestCalcDate?.toIso8601String(),
    'remark': remark,
    'direction': direction?.value,
    'status': status?.value,
    'interestType': interestType?.value,
    'contact': contact?.toJson(),
  };

  @override
  List<Object?> get props => [
    id,
    contactId,
    interestRate,
    initialPrincipal,
    startDate,
    dueDate,
    lastInterestCalcDate,
    remark,
    direction,
    status,
    interestType,
    contact,
    repayments,
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, contactId: $contactId, interestRate: $interestRate, initialPrincipal: $initialPrincipal,remainingPrincipal :$remainingPrincipal'
        ' startDate: $startDate, dueDate: $dueDate,lastInterestCalcDate: $lastInterestCalcDate, remark: $remark, direction: $direction, status: $status, interestType: $interestType, repayments: $repayments)';
  }
}
