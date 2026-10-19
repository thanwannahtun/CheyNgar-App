import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chey_ngar/models/contact.dart';
import 'package:chey_ngar/models/repayment.dart';
import 'package:chey_ngar/models/transactions.dart';
import 'package:chey_ngar/ui/screens/repayment_receipt_screen.dart';

void main() {
  testWidgets('RepaymentReceiptScreen renders voucher details correctly', (
    WidgetTester tester,
  ) async {
    final contact = Contact(
      id: 1,
      name: 'မောင်မောင်',
      phone: '09777123456',
    );

    final transaction = Transaction(
      id: 88,
      contactId: 1,
      contact: contact,
      initialPrincipal: 200000,
      remainingPrincipal: 150000,
      interestRate: 2.0,
      direction: TransactionDirection.lend,
      status: TransactionStatus.open,
    );

    final repayment = Repayment(
      id: 12,
      transactionId: 88,
      amountPaid: 50000,
      paymentDate: DateTime(2026, 10, 19),
      note: 'အရင်းနှင့်အတိုးဆပ်ငွေ',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RepaymentReceiptScreen(
          repayment: repayment,
          transaction: transaction,
        ),
      ),
    );

    await tester.pump();

    // Verify header and receipt title
    expect(find.text('ငွေပေးဆပ်မှုပြေစာ'), findsWidgets);
    expect(find.text('CHEY NGAR (အချေးအငှား)'), findsOneWidget);

    // Verify contact name and amount
    expect(find.text('မောင်မောင်'), findsOneWidget);
    expect(find.text('50,000 Ks'), findsOneWidget);

    // Verify format selector options
    expect(find.text('POS 80mm'), findsOneWidget);
    expect(find.text('A4 စာရွက်'), findsOneWidget);

    // Verify action buttons
    expect(find.text('POS ပရင့်ထုတ်မည်'), findsOneWidget);
    expect(find.text('မျှဝေမည်'), findsOneWidget);
  });
}
