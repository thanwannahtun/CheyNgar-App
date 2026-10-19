import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';

import '../../core/date_time_util.dart';
import '../../core/extensions/object_extension.dart';
import '../../models/repayment.dart';
import '../../models/transactions.dart';
import '../../services/receipt_pdf_service.dart';

enum ReceiptFormatOption {
  pos80('POS 80mm စက္ကူ (Roll)', ReceiptPdfService.roll80Tight, Icons.receipt),
  a4(
    'A4 စာရွက် (Standard)',
    ReceiptPdfService.a4Tight,
    Icons.description_outlined,
  );

  final String label;
  final PdfPageFormat pageFormat;
  final IconData icon;
  const ReceiptFormatOption(this.label, this.pageFormat, this.icon);
}

class RepaymentReceiptScreen extends StatefulWidget {
  const RepaymentReceiptScreen({
    super.key,
    required this.repayment,
    required this.transaction,
  });

  final Repayment repayment;
  final Transaction transaction;

  @override
  State<RepaymentReceiptScreen> createState() => _RepaymentReceiptScreenState();
}

class _RepaymentReceiptScreenState extends State<RepaymentReceiptScreen> {
  ReceiptFormatOption _selectedFormat = ReceiptFormatOption.pos80;
  bool _isProcessing = false;

  Future<void> _handlePrint() async {
    setState(() => _isProcessing = true);
    try {
      await ReceiptPdfService.printReceipt(
        repayment: widget.repayment,
        transaction: widget.transaction,
        format: _selectedFormat.pageFormat,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ပရင့်ထုတ်ရာတွင် အမှားဖြစ်ပေါ်ပါသည်: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSharePdf() async {
    setState(() => _isProcessing = true);
    try {
      await ReceiptPdfService.shareReceiptPdf(
        repayment: widget.repayment,
        transaction: widget.transaction,
        format: _selectedFormat.pageFormat,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ပြေစာမျှဝေရာတွင် အမှားဖြစ်ပေါ်ပါသည်: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSaveToDevice() async {
    setState(() => _isProcessing = true);
    try {
      final savedPath = await ReceiptPdfService.savePdfToDevice(
        repayment: widget.repayment,
        transaction: widget.transaction,
        format: _selectedFormat.pageFormat,
      );
      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "ပြေစာ PDF ကို Downloads ဖိုင်တွဲတွင် သိမ်းဆည်းပြီးပါပြီ:\n$savedPath",
              ),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: "မျှဝေမည်",
                onPressed: _handleSharePdf,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ပြေစာ PDF သိမ်းဆည်းခြင်း မအောင်မြင်ပါ"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCopyOrShareText() async {
    final summary = ReceiptPdfService.buildReceiptSummaryText(
      repayment: widget.repayment,
      transaction: widget.transaction,
    );
    await Clipboard.setData(ClipboardData(text: summary));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "ပြေစာအကျဉ်းစာသားကို ကူးယူပြီးပါပြီ (Copied to Clipboard)",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLend = widget.transaction.direction == TransactionDirection.lend;
    final contactName = widget.transaction.contact?.name ?? "မသိရှိသူ";
    final contactPhone = widget.transaction.contact?.phone ?? "-";
    final receiptNo =
        "#REC-${widget.repayment.id ?? DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    final paymentDateStr = widget.repayment.paymentDate != null
        ? DateTimeUtil.formatDate(widget.repayment.paymentDate!)
        : DateTimeUtil.formatDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("ငွေပေးဆပ်မှုပြေစာ"),
        actions: [
          IconButton(
            tooltip: "စာသား ကူးယူ/မျှဝေမည်",
            icon: const Icon(Icons.copy_rounded),
            onPressed: _handleCopyOrShareText,
          ),
          IconButton(
            tooltip: "ပြေစာမျှဝေမည်",
            icon: const Icon(Icons.share_outlined),
            onPressed: _isProcessing ? null : _handleSharePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Print Format Selector (POS Thermal Roll 80mm vs Standard A4)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withAlpha(80),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.print_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "ပရင်တာ ပုံစံ:",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SegmentedButton<ReceiptFormatOption>(
                      segments: ReceiptFormatOption.values
                          .map(
                            (opt) => ButtonSegment<ReceiptFormatOption>(
                              value: opt,
                              label: Text(
                                opt == ReceiptFormatOption.pos80
                                    ? "POS 80mm"
                                    : "A4 စာရွက်",
                                style: const TextStyle(fontSize: 12),
                              ),
                              icon: Icon(opt.icon, size: 14),
                            ),
                          )
                          .toList(),
                      selected: {_selectedFormat},
                      onSelectionChanged:
                          (Set<ReceiptFormatOption> newSelection) {
                            setState(() {
                              _selectedFormat = newSelection.first;
                            });
                          },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // The Minimalist Paper Receipt Card
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withAlpha(120),
                        width: 0.8,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header: App Logo / Receipt Title
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(150),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/images/cheyngar.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CHEY NGAR (အချေးအငှား)",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "ငွေပေးဆပ်မှုပြေစာ (Repayment Receipt)",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Receipt serial & date
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withAlpha(80),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  receiptNo,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  paymentDateStr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          _dashedDivider(colorScheme),
                          const SizedBox(height: 16),

                          // Highlighted Amount Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "ပေးသွင်းငွေပမာဏ (Amount Paid)",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${widget.repayment.amountPaid?.toCurrency ?? 0} Ks",
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ),
                                if (widget.repayment.paymentType != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.repayment.paymentType?.value ==
                                              'INTEREST_ONLY'
                                          ? "အတိုးသီးသန့် (Interest Only)"
                                          : widget
                                                    .repayment
                                                    .paymentType
                                                    ?.value ==
                                                'PRINCIPAL_ONLY'
                                          ? "အရင်းသီးသန့် (Principal Only)"
                                          : "အတိုးနှင့်အရင်း (Interest & Principal)",
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Repayment Note (if present)
                          if (widget.repayment.note != null &&
                              widget.repayment.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withAlpha(60),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "မှတ်ချက်: ${widget.repayment.note!.trim()}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          _dashedDivider(colorScheme),
                          const SizedBox(height: 14),

                          // Transaction Details Section
                          _receiptRow(
                            label: "ချေးငွေမှတ်တမ်းအမှတ်",
                            value: "#TXN-${widget.transaction.id ?? '-'}",
                            theme: theme,
                          ),
                          _receiptRow(
                            label: "အမျိုးအစား",
                            value: isLend
                                ? "ငွေထုတ်ချေးမှု (Lend)"
                                : "ငွေချေးယူမှု (Borrow)",
                            theme: theme,
                          ),
                          _receiptRow(
                            label: "ဆက်သွယ်ရန်သူ",
                            value: contactName,
                            theme: theme,
                            valueBold: true,
                          ),
                          if (contactPhone.isNotEmpty && contactPhone != "-")
                            _receiptRow(
                              label: "ဖုန်းနံပါတ်",
                              value: contactPhone,
                              theme: theme,
                            ),

                          const SizedBox(height: 10),
                          _dashedDivider(colorScheme),
                          const SizedBox(height: 10),

                          // Financial Balances Section
                          _receiptRow(
                            label: "မူလအရင်းငွေ",
                            value:
                                "${widget.transaction.initialPrincipal?.toCurrency ?? 0} Ks",
                            theme: theme,
                          ),
                          if (widget.transaction.interestRate != null)
                            _receiptRow(
                              label: "အတိုးနှုန်း",
                              value: "${widget.transaction.interestRate} %",
                              theme: theme,
                            ),
                          _receiptRow(
                            label: "ကျန်ရှိငွေပမာဏ",
                            value:
                                "${widget.transaction.remainingPrincipal?.toCurrency ?? 0} Ks",
                            theme: theme,
                            valueBold: true,
                            valueColor: colorScheme.error,
                          ),
                          _receiptRow(
                            label: "လက်ရှိအခြေအနေ",
                            value:
                                widget.transaction.status?.displayMM ??
                                widget.transaction.status?.name ??
                                "-",
                            theme: theme,
                          ),

                          const SizedBox(height: 16),
                          _dashedDivider(colorScheme),
                          const SizedBox(height: 16),

                          // Signature lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 1,
                                      width: 90,
                                      color: colorScheme.outlineVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "ပေးချေသူထိုးမြဲ",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 1,
                                      width: 90,
                                      color: colorScheme.outlineVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "လက်ခံသူထိုးမြဲ",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          _dashedDivider(colorScheme),
                          const SizedBox(height: 12),

                          // Footer Note
                          Text(
                            "★ ကျေးဇူးတင်ပါသည် (Thank You) ★",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "CheyNgar Smart Financial Ledger System",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withAlpha(
                                160,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Action Buttons
              Row(
                spacing: 10,
                children: [
                  // Print button (Primary)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handlePrint,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.print_rounded),
                      label: Text(
                        _selectedFormat == ReceiptFormatOption.pos80
                            ? "POS ပရင့်ထုတ်မည်"
                            : "ပရင့်ထုတ်မည်",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Share PDF Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _handleSharePdf,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text("မျှဝေမည်"),
                    ),
                  ),

                  // Save to Device Button
                  IconButton.filledTonal(
                    tooltip: "PDF သိမ်းဆည်းမည်",
                    onPressed: _isProcessing ? null : _handleSaveToDevice,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save_alt_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow({
    required String label,
    required String value,
    required ThemeData theme,
    bool valueBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withAlpha(150),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
