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
  open('OPEN', Colors.blue, "ဖွင့်ထားဆဲ"),
  settled('SETTLED', Colors.green, "ရှင်းပြီး"),
  overdue('OVERDUE', Colors.orange, "ရက်လွန်"),
  writtenOff('WRITTEN_OFF', Colors.red, "ကြွေးဆုံး"), // Money lost
  forgiven('FORGIVEN', Colors.purple, "လျှော်ပေးသည်"); // Debt cancelled

  final String value;
  final String displayMM;
  final Color color;

  const TransactionStatus(this.value, this.color, this.displayMM);

  static TransactionStatus fromString(String str) {
    return TransactionStatus.values.firstWhere(
      (e) =>
          e.value.toUpperCase() == str.toUpperCase() ||
          e.name.toUpperCase() == str.replaceAll('_', '').toUpperCase(),
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
  final String? closureReason;
  final int? guarantorContactId;
  final Contact? guarantor;
  final String? collateralDescription;
  final double? collateralValue;
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
    this.closureReason,
    this.guarantorContactId,
    this.guarantor,
    this.collateralDescription,
    this.collateralValue,
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
    String? closureReason,
    int? guarantorContactId,
    Contact? guarantor,
    String? collateralDescription,
    double? collateralValue,
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
    closureReason: closureReason ?? this.closureReason,
    guarantorContactId: guarantorContactId ?? this.guarantorContactId,
    guarantor: guarantor ?? this.guarantor,
    collateralDescription:
        collateralDescription ?? this.collateralDescription,
    collateralValue: collateralValue ?? this.collateralValue,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    interestType: interestType ?? this.interestType,
    contact: contact ?? this.contact,
    repayments: repayments ?? this.repayments,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    contactId: json['contactId'],
    initialPrincipal: json['initialPrincipal'] != null
        ? double.parse(json['initialPrincipal'].toString())
        : null,
    remainingPrincipal: json['remainingPrincipal'] != null
        ? double.parse(json['remainingPrincipal'].toString())
        : null,
    interestRate: json['interestRate'] != null
        ? double.parse(json['interestRate'].toString())
        : null,
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
    closureReason: json['closureReason'],
    guarantorContactId: json['guarantorContactId'],
    guarantor: json['guarantor'] != null
        ? Contact.fromJson(json['guarantor'])
        : null,
    collateralDescription: json['collateralDescription'],
    collateralValue: json['collateralValue'] != null
        ? double.tryParse(json['collateralValue'].toString())
        : null,
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
    if (id != null) 'id': id,
    if (contactId != null) 'contactId': contactId,
    if (interestRate != null) 'interestRate': interestRate,
    if (initialPrincipal != null) 'initialPrincipal': initialPrincipal,
    if (remainingPrincipal != null) 'remainingPrincipal': remainingPrincipal,
    if (startDate != null) 'startDate': startDate?.toIso8601String(),
    if (dueDate != null) 'dueDate': dueDate?.toIso8601String(),
    if (lastInterestCalcDate != null)
      'lastInterestCalcDate': lastInterestCalcDate?.toIso8601String(),
    if (remark != null) 'remark': remark,
    if (closureReason != null) 'closureReason': closureReason,
    if (guarantorContactId != null) 'guarantorContactId': guarantorContactId,
    if (collateralDescription != null)
      'collateralDescription': collateralDescription,
    if (collateralValue != null) 'collateralValue': collateralValue,
    if (direction != null) 'direction': direction?.value,
    if (status != null) 'status': status?.value,
    if (interestType != null) 'interestType': interestType?.value,
    if (contact != null) 'contact': contact?.toJson(),
  };

  @override
  List<Object?> get props => [
    id,
    contactId,
    interestRate,
    initialPrincipal,
    remainingPrincipal,
    startDate,
    dueDate,
    lastInterestCalcDate,
    remark,
    closureReason,
    guarantorContactId,
    guarantor,
    collateralDescription,
    collateralValue,
    direction,
    status,
    interestType,
    contact,
    repayments,
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, contactId: $contactId, interestRate: $interestRate, initialPrincipal: $initialPrincipal, remainingPrincipal: $remainingPrincipal, startDate: $startDate, dueDate: $dueDate, lastInterestCalcDate: $lastInterestCalcDate, remark: $remark, closureReason: $closureReason, direction: $direction, status: $status, interestType: $interestType, guarantor: $guarantor, collateralDescription: $collateralDescription, collateralValue: $collateralValue, repayments: $repayments)';
  }
}
