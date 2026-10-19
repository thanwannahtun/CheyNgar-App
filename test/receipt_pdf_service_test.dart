import 'package:chey_ngar/models/contact.dart';
import 'package:chey_ngar/models/repayment.dart';
import 'package:chey_ngar/models/transactions.dart';
import 'package:chey_ngar/services/receipt_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testContact = Contact(
    id: 1,
    name: 'ဦးဘမောင်',
    phone: '09123456789',
    nrc: '12/DAGAMA(N)123456',
  );

  final testTransaction = Transaction(
    id: 101,
    contactId: 1,
    contact: testContact,
    initialPrincipal: 500000,
    remainingPrincipal: 450000,
    interestRate: 3.5,
    startDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 12, 31),
    direction: TransactionDirection.lend,
    status: TransactionStatus.open,
  );

  final testRepayment = Repayment(
    id: 55,
    transactionId: 101,
    amountPaid: 50000,
    paymentDate: DateTime(2026, 10, 19),
    paymentType: PaymentType.both,
    note: '၁၀ လပိုင်း အတိုးနှင့်အရင်းပေးသွင်းငွေ',
  );

  group('ReceiptPdfService Tests', () {
    test('buildReceiptSummaryText generates clean structured receipt text', () {
      final summary = ReceiptPdfService.buildReceiptSummaryText(
        repayment: testRepayment,
        transaction: testTransaction,
      );

      expect(summary, contains('CheyNgar - ငွေပေးဆပ်မှုပြေစာ'));
      expect(summary, contains('#REC-55'));
      expect(summary, contains('#TXN-101'));
      expect(summary, contains('ဦးဘမောင်'));
      expect(summary, contains('09123456789'));
      expect(summary, contains('50,000 Ks'));
      expect(summary, contains('450,000 Ks'));
      expect(summary, contains('3.5%'));
      expect(summary, contains('၁၀ လပိုင်း အတိုးနှင့်အရင်းပေးသွင်းငွေ'));
    });

    test('generateReceiptPdf generates valid PDF bytes for POS 80mm format', () async {
      final bytes = await ReceiptPdfService.generateReceiptPdf(
        repayment: testRepayment,
        transaction: testTransaction,
        format: ReceiptPdfService.roll80Tight,
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      // PDF file magic bytes: %PDF
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });

    test('generateReceiptPdf generates valid PDF bytes for A4 format', () async {
      final bytes = await ReceiptPdfService.generateReceiptPdf(
        repayment: testRepayment,
        transaction: testTransaction,
        format: ReceiptPdfService.a4Tight,
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });
  });
}
