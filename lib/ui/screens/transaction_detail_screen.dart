import 'package:chey_ngar/core/extensions/object_extension.dart';
import 'package:chey_ngar/models/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../bloc/transaction_detail/transaction_detail_cubit.dart';
import '../../core/date_time_util.dart';
import '../widgets/error_message.dart';
import '../widgets/loading.dart';
import '../widgets/no_data.dart';
import 'repayment_create_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  int transactionId = 0;

  @override
  void initState() {
    super.initState();
    transactionId = widget.transactionId;
    context.read<TransactionDetailCubit>().fetchTransactionDetail(
      transactionId,
    );
  }

  void _showStatusChangeDialog({
    required TransactionStatus newStatus,
    required String title,
    required String confirmButtonText,
    bool requireReason = false,
  }) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: MediaQuery.sizeOf(context).width * 0.05,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (newStatus == TransactionStatus.writtenOff)
                const Text(
                  "💡 ဤချေးငွေကို 'ကြွေးဆုံး' အဖြစ် သတ်မှတ်ပါက ကျန်ရှိသော အရင်းငွေကို အရှုံးစာရင်း (Bad Debt Expense) သို့ ထည့်သွင်းမည်ဖြစ်ပြီး အတိုးတွက်ချက်မှု ရပ်ဆိုင်းပါမည်။",
                  style: TextStyle(fontSize: 13, color: Colors.amber),
                ),
              if (newStatus == TransactionStatus.forgiven)
                const Text(
                  "💡 ဤချေးငွေကို 'လျှော်ပေးသည်' အဖြစ် သတ်မှတ်ပါက ကြွေးမြီပယ်ဖျက်စာရင်း (Debt Forgiveness) သို့ ထည့်သွင်းမည်ဖြစ်ပြီး အတိုးတွက်ချက်မှု ရပ်ဆိုင်းပါမည်။",
                  style: TextStyle(fontSize: 13, color: Colors.amber),
                ),
              if (newStatus == TransactionStatus.settled)
                const Text(
                  "💡 ဤချေးငွေကို 'ရှင်းပြီး' အဖြစ်သို့ ထည့်သွင်းမည်ဖြစ်ပြီး အတိုးတွက်ချက်မှု ရပ်ဆိုင်းပါမည်။",
                  style: TextStyle(fontSize: 13, color: Colors.amber),
                ),
              if (requireReason) const SizedBox(height: 24),
              if (requireReason)
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "အကြောင်းပြချက် / အကြောင်းရင်း (Reason)",
                    alignLabelWithHint: true,
                    hintText:
                        "ဥပမာ- ဆုံးပါးသွားခြင်း၊ ထွက်ပြေးတိမ်းရှောင်ခြင်း၊ အခက်အခဲ",
                  ),
                  maxLines: 5,
                ),
            ],
          ),
        ),
        bottomNavigationBar: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("မလုပ်တော့ပါ"),
              ),
              BlocConsumer<TransactionDetailCubit, TransactionDetailState>(
                builder: (BuildContext context, TransactionDetailState state) {
                  final loading =
                      state.statusChangeStatus == BlocStatus.loading;
                  return ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            context.read<TransactionDetailCubit>().updateStatus(
                              transactionId,
                              status: newStatus,
                              closureReason: reasonController.text.trim(),
                            );
                          },
                    child: Row(
                      children: [
                        if (loading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        if (loading) const SizedBox(width: 8),
                        Text(
                          confirmButtonText,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
                listener: (BuildContext context, TransactionDetailState state) {
                  if (state.statusChangeStatus == BlocStatus.success) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionDetailCubit, TransactionDetailState>(
      listener: (context, state) {
        if (state.statusChangeStatus == BlocStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "အခြေအနေ ပြောင်းလဲပြီးပါပြီ"),
            ),
          );
        }
        if (state.statusChangeStatus == BlocStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? "အခြေအနေ ပြောင်းလဲမှု မအောင်မြင်ပါ",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isClosed =
            state.transaction?.status == TransactionStatus.settled ||
            state.transaction?.status == TransactionStatus.writtenOff ||
            state.transaction?.status == TransactionStatus.forgiven;

        return Scaffold(
          floatingActionButton: (state.status != BlocStatus.success || isClosed)
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => const RepaymentCreateScreen(),
                    );
                  },
                  tooltip: "New Repayment",
                  icon: const Icon(Icons.add),
                  label: const Text("ပြန်ဆပ်ငွေသွင်းမည်"),
                ),

          appBar: AppBar(
            title: const Text("အသေးစိတ်မှတ်တမ်း"),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              if (state.status == BlocStatus.success &&
                  state.transaction != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Status Options",
                  onSelected: (value) {
                    if (value == 'WRITE_OFF') {
                      _showStatusChangeDialog(
                        newStatus: TransactionStatus.writtenOff,
                        title: "ကြွေးဆုံးအဖြစ် သတ်မှတ်မည် (Write-Off)",
                        confirmButtonText: "ကြွေးဆုံးသတ်မှတ်မည်",
                        requireReason: true,
                      );
                    } else if (value == 'FORGIVE') {
                      _showStatusChangeDialog(
                        newStatus: TransactionStatus.forgiven,
                        title: "ကြွေးလျှော်ပေးမည် (Forgive Debt)",
                        confirmButtonText: "လျှော်ပေးမည်",
                        requireReason: true,
                      );
                    } else if (value == 'SETTLE') {
                      _showStatusChangeDialog(
                        newStatus: TransactionStatus.settled,
                        title: "ကျေပွန်/ရှင်းပြီးအဖြစ် သတ်မှတ်မည်",
                        confirmButtonText: "ရှင်းပြီးသတ်မှတ်မည်",
                        requireReason: false,
                      );
                    } else if (value == 'REOPEN') {
                      _showStatusChangeDialog(
                        newStatus: TransactionStatus.open,
                        title: "ပြန်လည်ဖွင့်မည် (Reopen)",
                        confirmButtonText: "ပြန်ဖွင့်မည်",
                        requireReason: false,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (state.transaction?.status !=
                        TransactionStatus.writtenOff)
                      const PopupMenuItem(
                        value: 'WRITE_OFF',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text("ကြွေးဆုံးအဖြစ် သတ်မှတ်မည်"),
                          ],
                        ),
                      ),
                    if (state.transaction?.status != TransactionStatus.forgiven)
                      const PopupMenuItem(
                        value: 'FORGIVE',
                        child: Row(
                          children: [
                            Icon(
                              Icons.volunteer_activism,
                              color: Colors.purple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text("ကြွေးလျှော်ပေးမည်"),
                          ],
                        ),
                      ),
                    if (state.transaction?.status != TransactionStatus.settled)
                      const PopupMenuItem(
                        value: 'SETTLE',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text("ရှင်းပြီးအဖြစ် သတ်မှတ်မည်"),
                          ],
                        ),
                      ),
                    if (isClosed)
                      const PopupMenuItem(
                        value: 'REOPEN',
                        child: Row(
                          children: [
                            Icon(Icons.replay, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text("ပြန်လည်ဖွင့်မည် (Reopen)"),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: () {
            if (state.status == BlocStatus.initial ||
                state.status == BlocStatus.loading) {
              return const Loading();
            }

            if (state.status == BlocStatus.failure) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorMessage(
                  message: state.message ?? "❌ Error!",
                  onRetry: () {
                    context
                        .read<TransactionDetailCubit>()
                        .fetchTransactionDetail(transactionId);
                  },
                ),
              );
            }

            if (state.transaction == null) {
              return const NoData(message: "No Transaction Found");
            }

            final txn = state.transaction!;

            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<TransactionDetailCubit>().fetchTransactionDetail(
                    transactionId,
                  );
                },
                child: ListView(
                  children: [
                    // Status Closure Banner (If written off or forgiven)
                    if (txn.status == TransactionStatus.writtenOff ||
                        txn.status == TransactionStatus.forgiven)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (txn.status?.color ?? Colors.grey).withAlpha(
                            25,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: txn.status?.color ?? Colors.grey,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              txn.status == TransactionStatus.writtenOff
                                  ? Icons.error_outline
                                  : Icons.volunteer_activism,
                              color: txn.status?.color,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    txn.status == TransactionStatus.writtenOff
                                        ? "ကြွေးဆုံးအဖြစ် သတ်မှတ်ထားသည် (Written-Off)"
                                        : "ကြွေးလျှော်ပေးထားသည် (Debt Forgiven)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: txn.status?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (txn.closureReason != null &&
                                      txn.closureReason!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "အကြောင်းရင်း: ${txn.closureReason}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "အတိုးတွက်ချက်မှုနှင့် ပြန်ဆပ်ငွေသွင်းခြင်းကို ရပ်ဆိုင်းထားပါသည်။",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Primary Transaction Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                txn.contact?.name ?? "-",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (txn.status?.color ?? Colors.blue)
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  txn.status?.displayMM ??
                                      txn.status?.name ??
                                      "-",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: txn.status?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              _infoRow(
                                label: "ရက်စွဲ",
                                value: txn.startDate != null
                                    ? DateTimeUtil.formatDate(txn.startDate!)
                                    : "-",
                              ),
                              _infoRow(
                                label: "ချေးငွေမူလပမာဏ",
                                value: txn.initialPrincipal?.toCurrency ?? "-",
                              ),
                              _infoRow(
                                label: "ပေးရန်ကျန်ငွေ",
                                value:
                                    txn.remainingPrincipal?.toCurrency ?? "-",
                              ),
                              _infoRow(
                                label: "အတိုးနှုန်း",
                                value: txn.interestRate != null
                                    ? "${txn.interestRate} %"
                                    : "-",
                              ),
                              if (txn.dueDate != null)
                                _infoRow(
                                  label: "ပေးဆပ်ရမည့်ရက်",
                                  value: DateTimeUtil.formatDate(txn.dueDate!),
                                ),
                              if (txn.remark != null && txn.remark!.isNotEmpty)
                                _infoRow(
                                  label: "မှတ်ချက်",
                                  value: txn.remark ?? "-",
                                ),
                              _infoRow(
                                label: "နောက်ဆုံးအတိုးတွက်ရက်",
                                value: txn.lastInterestCalcDate != null
                                    ? DateTimeUtil.formatDate(
                                        txn.lastInterestCalcDate!,
                                      )
                                    : "-",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Optional Guarantor & Collateral Info Card (If present)
                    if (txn.guarantor != null ||
                        (txn.collateralDescription != null &&
                            txn.collateralDescription!.isNotEmpty))
                      Card(
                        // margin: const EdgeInsets.only(top: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "အာမခံနှင့် အပေါင်ပစ္စည်း အချက်အလက်",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              if (txn.guarantor != null) ...[
                                _infoRow(
                                  label: "အာမခံသူ (Guarantor)",
                                  value: txn.guarantor?.name ?? "-",
                                ),
                                if (txn.guarantor?.phone != null)
                                  _infoRow(
                                    label: "အာမခံသူ ဖုန်း",
                                    value: txn.guarantor?.phone ?? "-",
                                  ),
                                if (txn.guarantor?.nrc != null)
                                  _infoRow(
                                    label: "အာမခံသူ မှတ်ပုံတင်",
                                    value: txn.guarantor?.nrc ?? "-",
                                  ),
                              ],
                              if (txn.collateralDescription != null &&
                                  txn.collateralDescription!.isNotEmpty) ...[
                                _infoRow(
                                  label: "အပေါင်ပစ္စည်း",
                                  value: txn.collateralDescription!,
                                ),
                                if (txn.collateralValue != null &&
                                    txn.collateralValue! > 0)
                                  _infoRow(
                                    label: "ခန့်မှန်းတန်ဖိုး",
                                    value: txn.collateralValue!.toCurrency,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // Repayments Header & List
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                        bottom: 6,
                        left: 4,
                        right: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ပြန်ဆပ်မှတ်တမ်းများ (${(txn.repayments ?? []).length})",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    if ((txn.repayments ?? []).isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text("ပြန်ဆပ်မှတ်တမ်း မရှိသေးပါ")),
                      ),

                    if ((txn.repayments ?? []).isNotEmpty)
                      ...List.generate(txn.repayments!.length, (index) {
                        final repayment = txn.repayments![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  repayment.amountPaid?.toCurrency ?? "-",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  repayment.paymentDate != null
                                      ? DateTimeUtil.formatDate(
                                          repayment.paymentDate!,
                                        )
                                      : "-",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            subtitle:
                                (repayment.note != null &&
                                    repayment.note!.isNotEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      repayment.note!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            );
          }(),
        );
      },
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
