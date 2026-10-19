import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../core/date_time_util.dart';
import '../core/extensions/object_extension.dart';
import '../core/rabbit/rabbit_converter.dart';
import '../models/repayment.dart';
import '../models/transactions.dart';

class ReceiptPdfService {
  static pw.Font? _cachedZawgyiFont;
  static pw.MemoryImage? _cachedLogo;

  /// Loads Zawgyi font (ZAWGYI-ONE_V3.1.TTF) from assets for crystal-clear Myanmar rendering in PDF/print
  static Future<pw.Font?> _loadZawgyiFont() async {
    if (_cachedZawgyiFont != null) return _cachedZawgyiFont;
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/ZAWGYI-ONE_V3.1.TTF',
      );
      _cachedZawgyiFont = pw.Font.ttf(fontData);
    } catch (e) {
      debugPrint('Could not load ZAWGYI-ONE font for PDF: $e');
    }
    return _cachedZawgyiFont;
  }

  /// Loads the CheyNgar logo image for the receipt voucher
  static Future<pw.MemoryImage?> _loadLogo() async {
    if (_cachedLogo != null) return _cachedLogo;
    try {
      final data = await rootBundle.load('assets/images/cheyngar.png');
      _cachedLogo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Could not load logo for PDF: $e');
    }
    return _cachedLogo;
  }

  /// Convert Unicode text to Zawgyi encoding for ZAWGYI-ONE_V3.1 font in PDF
  static String _zg(String text) {
    if (text.isEmpty) return text;
    return Rabbit.uni2zg(text);
  }

  /// Compact page format for thermal roll printers with tight margins
  static const PdfPageFormat roll80Tight = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 2.5 * PdfPageFormat.mm,
  );

  /// Compact page format for standard A4 printers
  static const PdfPageFormat a4Tight = PdfPageFormat(
    100 * PdfPageFormat.mm,
    297 * PdfPageFormat.mm,
    marginAll: 8 * PdfPageFormat.mm,
  );

  /// Generates the PDF bytes for the repayment receipt voucher with compact spacing.
  static Future<Uint8List> generateReceiptPdf({
    required Repayment repayment,
    required Transaction transaction,
    PdfPageFormat format = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 2.5 * PdfPageFormat.mm,
    ),
  }) async {
    final pdf = pw.Document();
    final zawgyiFont = await _loadZawgyiFont();
    final logoImage = await _loadLogo();

    final theme = zawgyiFont != null
        ? pw.ThemeData.withFont(base: zawgyiFont, bold: zawgyiFont)
        : pw.ThemeData();

    final isRoll = format.width <= 100 * PdfPageFormat.mm;
    final pageFormat = isRoll
        ? const PdfPageFormat(
            80 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 2.5 * PdfPageFormat.mm,
          )
        : const PdfPageFormat(
            100 * PdfPageFormat.mm,
            297 * PdfPageFormat.mm,
            marginAll: 8 * PdfPageFormat.mm,
          );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: theme,
        build: (pw.Context context) {
          final content = _buildReceiptContent(
            repayment: repayment,
            transaction: transaction,
            logoImage: logoImage,
            isRoll: isRoll,
          );

          if (!isRoll) {
            // For standard A4 paper, render a centered compact voucher card
            return pw.Center(
              child: pw.Container(
                width: 290,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: content,
              ),
            );
          }

          // For thermal POS roll paper, use full roll width with compact padding
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
            child: content,
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildReceiptContent({
    required Repayment repayment,
    required Transaction transaction,
    required pw.MemoryImage? logoImage,
    required bool isRoll,
  }) {
    final isLend = transaction.direction == TransactionDirection.lend;
    final transactionTypeLabel = isLend
        ? "ငွေထုတ်ချေးမှု (Lend)"
        : "ငွေချေးယူမှု (Borrow)";
    final contactName = transaction.contact?.name ?? "မသိရှိသူ";
    final contactPhone = transaction.contact?.phone ?? "-";
    final receiptNumber =
        "#REC-${repayment.id ?? DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    final dateStr = repayment.paymentDate != null
        ? DateTimeUtil.formatDate(repayment.paymentDate!)
        : DateTimeUtil.formatDate(DateTime.now());

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // CheyNgar Brand Logo & Title
        if (logoImage != null) ...[
          pw.Center(
            child: pw.Image(
              logoImage,
              height: isRoll ? 26 : 30,
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 2),
        ],

        pw.Text(
          _zg("CHEY NGAR (အချေးအငှား)"),
          style: pw.TextStyle(
            fontSize: isRoll ? 12 : 13.5,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          _zg("ငွေပေးဆပ်မှုပြေစာ (Repayment Receipt)"),
          style: pw.TextStyle(
            fontSize: isRoll ? 8.5 : 9.5,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),

        // Receipt No & Date
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              receiptNumber,
              style: pw.TextStyle(
                fontSize: isRoll ? 8 : 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.Text(
              _zg("ရက်စွဲ: $dateStr"),
              style: pw.TextStyle(
                fontSize: isRoll ? 7.5 : 8,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 3),
        _dashedLine(),
        pw.SizedBox(height: 3),

        // Transaction & Contact Details
        _infoRow(
          _zg("ချေးငွေမှတ်တမ်းအမှတ်"),
          "#TXN-${transaction.id ?? '-'}",
          isRoll,
        ),
        _infoRow(_zg("အမျိုးအစား"), _zg(transactionTypeLabel), isRoll),
        _infoRow(_zg("ဆက်သွယ်ရန်သူ"), _zg(contactName), isRoll),
        if (contactPhone.isNotEmpty && contactPhone != "-")
          _infoRow(_zg("ဖုန်းနံပါတ်"), contactPhone, isRoll),

        pw.SizedBox(height: 3),
        _dashedLine(),
        pw.SizedBox(height: 3),

        // Highlighted Amount Paid Box (Compact padding)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                _zg("ပေးသွင်းငွေပမာဏ (Amount Paid)"),
                style: pw.TextStyle(
                  fontSize: isRoll ? 7.5 : 8.5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                "${repayment.amountPaid?.toCurrency ?? 0} Ks",
                style: pw.TextStyle(
                  fontSize: isRoll ? 13 : 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
              if (repayment.paymentType != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1),
                  child: pw.Text(
                    _zg(
                      repayment.paymentType?.value == 'INTEREST_ONLY'
                          ? "အတိုးသီးသန့် (Interest Only)"
                          : repayment.paymentType?.value == 'PRINCIPAL_ONLY'
                          ? "အရင်းသီးသန့် (Principal Only)"
                          : "အတိုးနှင့်အရင်း (Interest & Principal)",
                    ),
                    style: pw.TextStyle(
                      fontSize: isRoll ? 7 : 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Repayment Note (if present)
        if (repayment.note != null && repayment.note!.trim().isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              _zg("မှတ်ချက်: ${repayment.note!.trim()}"),
              style: pw.TextStyle(
                fontSize: isRoll ? 7.5 : 8,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],

        pw.SizedBox(height: 3),
        _dashedLine(),
        pw.SizedBox(height: 3),

        // Loan Financial Balances Summary
        _infoRow(
          _zg("မူလအရင်းငွေ"),
          "${transaction.initialPrincipal?.toCurrency ?? 0} Ks",
          isRoll,
        ),
        if (transaction.interestRate != null)
          _infoRow(_zg("အတိုးနှုန်း"), "${transaction.interestRate} %", isRoll),
        _infoRow(
          _zg("ကျန်ရှိငွေ"),
          "${transaction.remainingPrincipal?.toCurrency ?? 0} Ks",
          isRoll,
          isBold: true,
        ),
        _infoRow(
          _zg("လက်ရှိအခြေအနေ"),
          _zg(transaction.status?.displayMM ?? transaction.status?.name ?? "-"),
          isRoll,
        ),

        pw.SizedBox(height: 4),
        _dashedLine(),
        pw.SizedBox(height: 6),

        // Signature Sections
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    width: isRoll ? 55 : 70,
                    height: 0.8,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _zg("ပေးချေသူထိုးမြဲ"),
                    style: pw.TextStyle(
                      fontSize: isRoll ? 7 : 7.5,
                      color: PdfColors.grey700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    width: isRoll ? 55 : 70,
                    height: 0.8,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _zg("လက်ခံသူထိုးမြဲ"),
                    style: pw.TextStyle(
                      fontSize: isRoll ? 7 : 7.5,
                      color: PdfColors.grey700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 6),
        _dashedLine(),
        pw.SizedBox(height: 3),

        // Compact Footer Note
        pw.Text(
          _zg("* ကျေးဇူးတင်ပါသည် (Thank You) *"),
          style: pw.TextStyle(
            fontSize: isRoll ? 7.5 : 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          "CheyNgar Smart Financial Ledger",
          style: pw.TextStyle(
            fontSize: isRoll ? 6 : 6.5,
            color: PdfColors.grey500,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _infoRow(
    String label,
    String value,
    bool isRoll, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isRoll ? 7.5 : 8,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isRoll ? 7.5 : 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.black : PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _dashedLine() {
    return pw.Row(
      children: List.generate(
        35,
        (index) => pw.Expanded(
          child: pw.Container(
            height: 0.5,
            color: index.isEven ? PdfColors.grey400 : PdfColors.white,
          ),
        ),
      ),
    );
  }

  /// Print receipt with standard print dialog (supports Bluetooth/USB mini thermal printers & office printers)
  static Future<void> printReceipt({
    required Repayment repayment,
    required Transaction transaction,
    PdfPageFormat format = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 2.5 * PdfPageFormat.mm,
    ),
  }) async {
    final receiptNo = repayment.id ?? DateTime.now().millisecondsSinceEpoch;
    await Printing.layoutPdf(
      name: 'CheyNgar_Receipt_$receiptNo.pdf',
      format: format,
      onLayout: (PdfPageFormat selectedFormat) async {
        return await generateReceiptPdf(
          repayment: repayment,
          transaction: transaction,
          format: selectedFormat,
        );
      },
    );
  }

  /// Share the actual PDF file directly to other platforms (Viber, Telegram, WhatsApp, Email, etc.)
  /// Does NOT share formatted plain text.
  static Future<void> shareReceiptPdf({
    required Repayment repayment,
    required Transaction transaction,
    PdfPageFormat format = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 2.5 * PdfPageFormat.mm,
    ),
  }) async {
    final pdfBytes = await generateReceiptPdf(
      repayment: repayment,
      transaction: transaction,
      format: format,
    );
    final receiptNo = repayment.id ?? DateTime.now().millisecondsSinceEpoch;
    final filename = 'CheyNgar_Receipt_$receiptNo.pdf';

    // Save temporarily and share as file attachment
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf', name: filename)],
        subject: filename,
      ),
    );
  }

  /// Resolves an easily visible download directory (e.g., standard public Downloads)
  static Future<Directory> getVisibleDownloadDirectory() async {
    if (Platform.isAndroid) {
      final androidDownloadDir = Directory('/storage/emulated/0/Download');
      if (await androidDownloadDir.exists()) {
        return androidDownloadDir;
      }
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) return extDir;
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return await getApplicationDocumentsDirectory();
  }

  /// Saves the PDF receipt into the device's visible Downloads directory
  /// Saves the PDF receipt into the device's visible Downloads directory
  static Future<String?> savePdfToDevice({
    required Repayment repayment,
    required Transaction transaction,
    PdfPageFormat format = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 2.5 * PdfPageFormat.mm,
    ),
  }) async {
    try {
      final bytes = await generateReceiptPdf(
        repayment: repayment,
        transaction: transaction,
        format: format,
      );
      final dir = await getVisibleDownloadDirectory();
      final receiptNo = repayment.id ?? DateTime.now().millisecondsSinceEpoch;

      int counter = 0;
      bool isSaved = false;
      File? savedFile;

      while (!isSaved) {
        try {
          // If counter is 0, use base name. Otherwise append (1), (2), etc.
          final suffix = counter == 0 ? '' : ' ($counter)';
          final fileName = 'CheyNgar_Receipt_$receiptNo$suffix.pdf';
          savedFile = File('${dir.path}/$fileName');

          // Fast path check for files the app CAN see
          if (await savedFile.exists()) {
            counter++;
            continue;
          }

          // Attempt to write. If Scoped Storage hides the file but prevents
          // overwriting, this will throw the FileSystemException.
          await savedFile.writeAsBytes(bytes);
          isSaved = true; // Success! Exit the loop.
        } on FileSystemException catch (e) {
          // OS Error 17 means the file exists.
          if (e.osError?.errorCode == 17) {
            counter++; // Increment and try the next number
          } else {
            // It's a different error (e.g., permission denied), so stop trying.
            rethrow;
          }
        }
      }

      return savedFile?.path;
    } catch (e) {
      debugPrint('Error saving PDF receipt: $e');
      return null;
    }
  }

  /// Build a clean, minimalist text receipt for clipboard copy in the AppBar
  static String buildReceiptSummaryText({
    required Repayment repayment,
    required Transaction transaction,
  }) {
    final isLend = transaction.direction == TransactionDirection.lend;
    final role = isLend ? "ချေးငွေ (Lend)" : "ချေးယူငွေ (Borrow)";
    final contactName = transaction.contact?.name ?? "မသိရှိသူ";
    final contactPhone = transaction.contact?.phone ?? "-";
    final amount = "${repayment.amountPaid?.toCurrency ?? 0} Ks";
    final date = repayment.paymentDate != null
        ? DateTimeUtil.formatDate(repayment.paymentDate!)
        : "-";
    final initialPrincipal =
        "${transaction.initialPrincipal?.toCurrency ?? 0} Ks";
    final remaining = "${transaction.remainingPrincipal?.toCurrency ?? 0} Ks";
    final receiptNo =
        "#REC-${repayment.id ?? DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    return '''
🧾 【 CheyNgar - ငွေပေးဆပ်မှုပြေစာ 】
--------------------------------
• ပြေစာအမှတ်: $receiptNo
• ချေးငွေအမှတ်: #TXN-${transaction.id ?? '-'}
• အမျိုးအစား: $role
• ဆက်သွယ်ရန်သူ: $contactName ($contactPhone)
• ပြန်ဆပ်သည့်ရက်: $date
--------------------------------
💰 ပေးသွင်းငွေ: $amount
• မူလအရင်းငွေ: $initialPrincipal
• အတိုးနှုန်း: ${transaction.interestRate ?? 0}%
• လက်ကျန်ငွေ: $remaining
• အခြေအနေ: ${transaction.status?.displayMM ?? "-"}
${repayment.note != null && repayment.note!.trim().isNotEmpty ? '• မှတ်ချက်: ${repayment.note!.trim()}\n' : ''}--------------------------------
* CheyNgar စနစ်ဖြင့် အတည်ပြုထုတ်ပေးထားသော ပြေစာဖြစ်ပါသည်။
'''
        .trim();
  }
}
