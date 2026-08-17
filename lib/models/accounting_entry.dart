import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'transactions.dart';

enum JournalEntryType {
  loanDisbursement('LOAN_DISBURSEMENT', 'ချေးငွေထုတ်ပေးခြင်း', Colors.blue, Icons.arrow_upward),
  loanReceipt('LOAN_RECEIPT', 'ချေးငွေရယူခြင်း', Colors.green, Icons.arrow_downward),
  repaymentReceived('REPAYMENT_RECEIVED', 'ပြန်ဆပ်ငွေလက်ခံခြင်း', Colors.teal, Icons.payments),
  repaymentMade('REPAYMENT_MADE', 'ပြန်လည်ပေးဆပ်ခြင်း', Colors.orange, Icons.payment),
  writeOff('WRITE_OFF', 'ကြွေးဆုံးသတ်မှတ်ခြင်း', Colors.red, Icons.cancel),
  forgiveness('FORGIVENESS', 'ကြွေးလျှော်ပေးခြင်း', Colors.purple, Icons.volunteer_activism),
  adjustment('ADJUSTMENT', 'စာရင်းညှိနှိုင်းခြင်း', Colors.grey, Icons.tune);

  final String value;
  final String displayMM;
  final Color color;
  final IconData icon;

  const JournalEntryType(this.value, this.displayMM, this.color, this.icon);

  static JournalEntryType fromString(String str) {
    return JournalEntryType.values.firstWhere(
      (e) =>
          e.value.toUpperCase() == str.toUpperCase() ||
          e.name.toUpperCase() == str.replaceAll('_', '').toUpperCase(),
      orElse: () => JournalEntryType.adjustment,
    );
  }
}

class JournalEntryItem extends Equatable {
  final int? id;
  final int? journalEntryId;
  final String accountCode;
  final String accountName;
  final String accountType; // 'ASSET' | 'LIABILITY' | 'EQUITY' | 'INCOME' | 'EXPENSE'
  final double debit;
  final double credit;
  final String? notes;

  const JournalEntryItem({
    this.id,
    this.journalEntryId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.debit,
    required this.credit,
    this.notes,
  });

  factory JournalEntryItem.fromJson(Map<String, dynamic> json) =>
      JournalEntryItem(
        id: json['id'],
        journalEntryId: json['journalEntryId'],
        accountCode: json['accountCode'] ?? '',
        accountName: json['accountName'] ?? '',
        accountType: json['accountType'] ?? 'ASSET',
        debit: double.parse((json['debit'] ?? 0).toString()),
        credit: double.parse((json['credit'] ?? 0).toString()),
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (journalEntryId != null) 'journalEntryId': journalEntryId,
    'accountCode': accountCode,
    'accountName': accountName,
    'accountType': accountType,
    'debit': debit,
    'credit': credit,
    if (notes != null) 'notes': notes,
  };

  @override
  List<Object?> get props => [
    id,
    journalEntryId,
    accountCode,
    accountName,
    accountType,
    debit,
    credit,
    notes,
  ];
}

class JournalEntry extends Equatable {
  final int? id;
  final int? userId;
  final int? transactionId;
  final int? repaymentId;
  final DateTime entryDate;
  final JournalEntryType entryType;
  final String description;
  final String? referenceNo;
  final List<JournalEntryItem> items;
  final Transaction? transaction;

  const JournalEntry({
    this.id,
    this.userId,
    this.transactionId,
    this.repaymentId,
    required this.entryDate,
    required this.entryType,
    required this.description,
    this.referenceNo,
    this.items = const [],
    this.transaction,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    userId: json['userId'],
    transactionId: json['transactionId'],
    repaymentId: json['repaymentId'],
    entryDate: json['entryDate'] != null
        ? DateTime.parse(json['entryDate'])
        : DateTime.now(),
    entryType: json['entryType'] != null
        ? JournalEntryType.fromString(json['entryType'])
        : JournalEntryType.adjustment,
    description: json['description'] ?? '',
    referenceNo: json['referenceNo'],
    items: json['items'] != null
        ? (json['items'] as List)
            .map((e) => JournalEntryItem.fromJson(e))
            .toList()
        : [],
    transaction: json['transaction'] != null
        ? Transaction.fromJson(json['transaction'])
        : null,
  );

  double get totalDebit =>
      items.fold(0.0, (sum, item) => sum + item.debit);
  double get totalCredit =>
      items.fold(0.0, (sum, item) => sum + item.credit);

  @override
  List<Object?> get props => [
    id,
    userId,
    transactionId,
    repaymentId,
    entryDate,
    entryType,
    description,
    referenceNo,
    items,
    transaction,
  ];
}

class AccountBalance extends Equatable {
  final String code;
  final String name;
  final String type;
  final double debit;
  final double credit;
  final double balance;

  const AccountBalance({
    required this.code,
    required this.name,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) => AccountBalance(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    debit: double.parse((json['debit'] ?? 0).toString()),
    credit: double.parse((json['credit'] ?? 0).toString()),
    balance: double.parse((json['balance'] ?? 0).toString()),
  );

  @override
  List<Object?> get props => [code, name, type, debit, credit, balance];
}

class FinancialSummary extends Equatable {
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
  final double totalInterestIncome;
  final double totalInterestExpense;
  final double totalBadDebtLoss;
  final double totalDebtForgiven;
  final double netProfitLoss;
  final List<AccountBalance> accounts;

  const FinancialSummary({
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
    required this.totalInterestIncome,
    required this.totalInterestExpense,
    required this.totalBadDebtLoss,
    required this.totalDebtForgiven,
    required this.netProfitLoss,
    required this.accounts,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    final trial = json['trialBalance'] ?? {};
    final pl = json['profitLoss'] ?? {};
    final rawAccounts = json['accounts'] as List? ?? [];

    return FinancialSummary(
      totalDebit: double.parse((trial['totalDebit'] ?? 0).toString()),
      totalCredit: double.parse((trial['totalCredit'] ?? 0).toString()),
      isBalanced: trial['isBalanced'] ?? true,
      totalInterestIncome:
          double.parse((pl['totalInterestIncome'] ?? 0).toString()),
      totalInterestExpense:
          double.parse((pl['totalInterestExpense'] ?? 0).toString()),
      totalBadDebtLoss:
          double.parse((pl['totalBadDebtLoss'] ?? 0).toString()),
      totalDebtForgiven:
          double.parse((pl['totalDebtForgiven'] ?? 0).toString()),
      netProfitLoss:
          double.parse((pl['netProfitLoss'] ?? 0).toString()),
      accounts: rawAccounts.map((e) => AccountBalance.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [
    totalDebit,
    totalCredit,
    isBalanced,
    totalInterestIncome,
    totalInterestExpense,
    totalBadDebtLoss,
    totalDebtForgiven,
    netProfitLoss,
    accounts,
  ];
}
