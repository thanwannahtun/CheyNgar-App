import 'package:chey_ngar/core/extensions/object_extension.dart';
import 'package:chey_ngar/core/extensions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../bloc/dropdown_data/dropdown_data_cubit.dart';
import '../../bloc/transactions/transactions_cubit.dart';
import '../../core/controller_record.dart';
import '../../core/date_time_util.dart';
import '../../models/contact.dart';
import '../../models/transactions.dart';
import '../widgets/dialogs/contact_selection_dialog.dart';
import '../widgets/error_message.dart';
import '../widgets/input_fields/enum_dropdown.dart';
import '../widgets/input_fields/input_form.dart';
import '../widgets/loading.dart';
import '../widgets/no_data.dart';
import 'transaction_create_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key, required this.direction});
  final TransactionDirection direction;

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  late TextEditingController transactionDateFilter;

  final _contactControllerRecord = ControllerRecord<Contact>(
    controller: TextEditingController(),
    model: null,
  );

  @override
  void initState() {
    super.initState();
    transactionDateFilter = TextEditingController();
    context.read<TransactionsCubit>().fetchTransactions(
      query: Transaction(direction: widget.direction),
    );
  }

  @override
  void dispose() {
    _contactControllerRecord.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DropdownDataCubit<TransactionStatus>>(
      create: (BuildContext context) =>
          DropdownDataCubit<TransactionStatus>(null),
      child: Builder(
        builder: (context) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) =>
                      TransactionCreateScreen(direction: widget.direction),
                );
              },
              tooltip: "New Transaction",
              child: Icon(Icons.add),
            ),
            appBar: AppBar(
              title: const Text("Transactions List"),

              actionsPadding: EdgeInsets.only(right: 16),
              actions: [
                IconButton(
                  onPressed: () {
                    showFilter(context);
                  },
                  // filter icon
                  icon: Icon(Icons.filter_list_rounded),
                ),
              ],
            ),
            body: BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                if (state.status == BlocStatus.initial ||
                    state.status == BlocStatus.loading) {
                  return Loading();
                }

                if (state.status == BlocStatus.failure) {
                  return ErrorMessage(
                    message: state.message ?? "❌Error!",
                    onRetry: () {
                      context.read<TransactionsCubit>().fetchTransactions(
                        query: Transaction(direction: widget.direction),
                      );
                    },
                  );
                }

                if (state.transactions == null ||
                    (state.transactions ?? []).isEmpty) {
                  return NoData(message: "No Transactions");
                }

                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    context.read<TransactionsCubit>().reloadLastQuery();
                  },
                  child: ListView.separated(
                    itemCount: state.transactions!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    itemBuilder: (context, index) {
                      final data = state.transactions![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                spacing: 8,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      Text(
                                        data.direction ==
                                                TransactionDirection.lend
                                            ? "ချေးသူ:"
                                            : "အကြွေးရှင်:",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      Text(
                                        data.contact?.name ?? "-",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  // status
                                  Text(
                                    data.status?.name ?? "-",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: data.status?.color),
                                  ),
                                ],
                              ),

                              subtitle: Column(
                                spacing: 6,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  _infoRow(
                                    label: "ချေးငွေပမာဏ",
                                    value:
                                        data.initialPrincipal?.toCurrency ??
                                        "-",
                                  ),
                                  _infoRow(
                                    label: "ရက်စွဲ",
                                    value: data.startDate != null
                                        ? DateTimeUtil.formatDate(
                                            data.startDate!,
                                          )
                                        : "-",
                                  ),

                                  _infoRow(
                                    label: "အတိုးနှုန်း",
                                    value: data.interestRate != null
                                        ? "${data.interestRate} %"
                                        : "-",
                                  ),
                                  _infoRow(
                                    label: "မှတ်ချက်",
                                    value: data.remark ?? "-",
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              title: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            transactionId: data.id ?? 0,
                                          ),
                                    ),
                                  );
                                },
                                child: Text("ကြည့်မည်").fittedBox(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
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

  showFilter(BuildContext context) {
    final dropdownCubit = context.read<DropdownDataCubit<TransactionStatus>>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: dropdownCubit,
        child: Builder(
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transaction Filter",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          label: Row(
                            spacing: 5,
                            children: [
                              Icon(Icons.refresh_rounded),
                              Text("ရှင်းမည်"),
                            ],
                          ),
                          onPressed: () {
                            clearFilter(context);
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "ချေးသည့်ရက်စွဲ",
                      ),
                      controller: transactionDateFilter,
                      readOnly: true,
                      onTap: () async {
                        final picked = await DateTimeUtil.showDatePickerDialog(
                          context,
                          initialDate: transactionDateFilter.text.isNotEmpty
                              ? DateTime.parse(transactionDateFilter.text)
                              : null,
                        );
                        if (picked != null) {
                          setState(() {
                            transactionDateFilter.text = picked
                                .toIso8601String()
                                .split("T")[0];
                          });
                        }
                      },
                    ),
                    InputForm(
                      label: widget.direction == TransactionDirection.borrow
                          ? "ချေးပေးသူအမည်"
                          : "ချေးသူအမည်",
                      controller: _contactControllerRecord.controller,
                      width: double.infinity,
                      readOnly: true,
                      onTap: (value) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog.fullscreen(
                            child: ContactSelectionDialog(
                              initialValue: _contactControllerRecord.model,
                              onSelected: (value) {
                                setState(() {
                                  _contactControllerRecord.controller.text =
                                      value.name ?? '-';
                                  _contactControllerRecord.model = value;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    EnumDropdown<TransactionStatus>(
                      label: "Payment Status",
                      items: TransactionStatus.values,
                    ),

                    ListTile(
                      title: ElevatedButton(
                        onPressed: () {
                          if (transactionDateFilter.text.isEmpty &&
                              _contactControllerRecord.model == null &&
                              dropdownCubit.state.data == null) {
                            return;
                          }

                          context.read<TransactionsCubit>().fetchTransactions(
                            query: Transaction(
                              direction: widget.direction,
                              contactId: _contactControllerRecord.model?.id,
                              startDate: DateTime.tryParse(
                                transactionDateFilter.text,
                              ),
                              status: context
                                  .read<DropdownDataCubit<TransactionStatus>>()
                                  .state
                                  .data,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: const Text("ရှာဖွေမည်"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  clearFilter(BuildContext context) {
    transactionDateFilter.clear();
    context.read<DropdownDataCubit<TransactionStatus>>().clearSelectedValue();
    _contactControllerRecord.controller.clear();
    _contactControllerRecord.model = null;
  }
}
