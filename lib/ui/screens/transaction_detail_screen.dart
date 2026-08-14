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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          BlocBuilder<TransactionDetailCubit, TransactionDetailState>(
            builder: (context, state) {
              if (state.status != BlocStatus.success) {
                return const SizedBox.shrink();
              }

              final isCompleted =
                  state.transaction?.status == TransactionStatus.settled;

              if (isCompleted) {
                return const SizedBox.shrink();
              }

              return FloatingActionButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => const RepaymentCreateScreen(),
                  );
                },
                tooltip: "New Repayment",
                child: const Icon(Icons.add),
              );
            },
          ),

      appBar: AppBar(
        title: const Text("Transaction Detail"),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [],
      ),
      body: BlocBuilder<TransactionDetailCubit, TransactionDetailState>(
        builder: (context, state) {
          if (state.status == BlocStatus.initial ||
              state.status == BlocStatus.loading) {
            return Loading();
          }

          if (state.status == BlocStatus.failure) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorMessage(
                message: state.message ?? "❌Error!",
                onRetry: () {
                  context.read<TransactionDetailCubit>().fetchTransactionDetail(
                    transactionId,
                  );
                },
              ),
            );
          }

          if (state.transaction == null) {
            return NoData(message: "No Transaction Found");
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: RefreshIndicator.adaptive(
              onRefresh: () async {
                context.read<TransactionDetailCubit>().fetchTransactionDetail(
                  transactionId,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// transaction info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.transaction?.contact?.name ?? "-",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            // status
                            Text(
                              state.transaction?.status?.name ?? "-",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: state.transaction?.status?.color,
                                  ),
                            ),
                          ],
                        ),

                        subtitle: Column(
                          spacing: 6,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            _infoRow(
                              label: "ရက်စွဲ",
                              value: state.transaction?.startDate != null
                                  ? DateTimeUtil.formatDate(
                                      state.transaction!.startDate!,
                                    )
                                  : "-",
                            ),
                            _infoRow(
                              label: "ချေးငွေ",
                              value:
                                  state
                                      .transaction
                                      ?.initialPrincipal
                                      ?.toCurrency ??
                                  "-",
                            ),
                            _infoRow(
                              label: "ပေးရန်ကျန်ငွေ",
                              value:
                                  state
                                      .transaction
                                      ?.remainingPrincipal
                                      ?.toCurrency ??
                                  "-",
                            ),

                            _infoRow(
                              label: "အတိုးနှုန်း",
                              value: state.transaction?.interestRate != null
                                  ? "${state.transaction!.interestRate} %"
                                  : "-",
                            ),
                            _infoRow(
                              label: "မှတ်ချက်",
                              value: state.transaction?.remark ?? "-",
                            ),
                            _infoRow(
                              label: "နောက်ဆုံးပေးချေရက်စွဲ",
                              value:
                                  state.transaction?.lastInterestCalcDate !=
                                      null
                                  ? DateTimeUtil.formatDate(
                                      state.transaction!.lastInterestCalcDate!,
                                    )
                                  : "-",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// repayments list
                  if ((state.transaction!.repayments ?? []).isEmpty)
                    Expanded(child: NoData(message: "No Repayments made yet")),
                  if ((state.transaction!.repayments ?? []).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ပြန်ဆပ်မှတ်တမ်းများ",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // view all mini button
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            child: const Text("view all"),
                          ),
                        ],
                      ),
                    ),
                  if ((state.transaction!.repayments ?? []).isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.transaction!.repayments!.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final repayment =
                              state.transaction!.repayments![index];
                          return Card(
                            child: ListTile(
                              title: Row(
                                spacing: 8,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        repayment.amountPaid?.toCurrency ?? "-",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    repayment.paymentDate != null
                                        ? DateTimeUtil.formatDate(
                                            repayment.paymentDate!,
                                          )
                                        : "-",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),

                                  if (repayment.note != null &&
                                      repayment.note!.isNotEmpty)
                                    Text("မှတ်ချက်: ${repayment.note}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
