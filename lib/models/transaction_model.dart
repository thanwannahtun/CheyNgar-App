import 'contact.dart';

enum TransactionType { borrow, lend }

class TransactionModel {
  final String id;
  final String personId;
  final TransactionType type;
  final int amount;
  final DateTime date;
  final String note;

  TransactionModel({
    required this.id,
    required this.personId,
    required this.type,
    required this.amount,
    required this.date,
    required this.note,
  });
}

final List<Person> borrowers = [
  Person(id: 'b1', name: 'မောင်မောင်', phone: '0912345678'),
  Person(id: 'b2', name: 'အောင်အောင်', phone: '0998765432'),
];

final List<Person> lenders = [
  Person(id: 'l1', name: 'ကိုကို', phone: '0922334455'),
  Person(id: 'l2', name: 'မမ', phone: '0944556677'),
];

final List<TransactionModel> transactions = [
  TransactionModel(
    id: 't1',
    personId: 'b1',
    type: TransactionType.borrow,
    amount: 150000,
    date: DateTime.now().subtract(const Duration(days: 2)),
    note: 'ဆိုင်ငှားခ',
  ),
  TransactionModel(
    id: 't2',
    personId: 'l1',
    type: TransactionType.lend,
    amount: 300000,
    date: DateTime.now().subtract(const Duration(days: 5)),
    note: 'အလုပ်အတွက်',
  ),
];
