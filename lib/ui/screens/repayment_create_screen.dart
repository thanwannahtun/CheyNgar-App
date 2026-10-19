import 'package:chey_ngar/core/extensions/object_extension.dart';

import '../../../core/extensions/navigator_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../bloc/transaction_detail/transaction_detail_cubit.dart';
import '../../models/repayment.dart';
import '../widgets/input_fields/date_picker.dart';
import 'repayment_receipt_screen.dart';

class RepaymentCreateScreen extends StatefulWidget {
  const RepaymentCreateScreen({super.key});

  @override
  State<RepaymentCreateScreen> createState() => _RepaymentCreateScreenState();
}

class _RepaymentCreateScreenState extends State<RepaymentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _remarkController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _remarkController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionDetailCubit, TransactionDetailState>(
      listenWhen: (prev, curr) => prev.crudStatus != curr.crudStatus,
      listener: (context, state) {
        if (state.crudStatus == BlocStatus.success) {
          final createdRepayment = state.repayment;
          final currentTransaction = state.transaction;
          final cubit = context.read<TransactionDetailCubit>();

          Navigator.of(context).pop();

          if (currentTransaction != null && createdRepayment != null) {
            cubit.fetchTransactionDetail(currentTransaction.id ?? 0);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RepaymentReceiptScreen(
                  repayment: createdRepayment,
                  transaction: currentTransaction,
                ),
              ),
            );
          }
        }
        if (state.crudStatus == BlocStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? "Something went wrong")),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.crudStatus == BlocStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text("ပြန်ဆပ်မှု အသစ်"),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.close),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: Text(
                                    "စုစုပေါင်းပေးရန်ကျန်ငွေ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  "${state.transaction?.remainingPrincipal?.toCurrency ?? 0.0} Ks",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            Divider(),
                            // amount number only
                            TextFormField(
                              controller: _amountController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "ပြန်ဆပ်ငွေပမာဏ",
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "ပြန်ဆပ်ငွေပမာဏ ထည့်ပါ";
                                }
                                if (double.tryParse(val.trim()) == null) {
                                  return "ပြန်ဆပ်ငွေပမာဏ မှန်ကန်မှုမရှိပါ";
                                }
                                return null;
                              },
                            ),
                            // date only picker
                            DatePickerFormField(
                              firstDate: DateTime(DateTime.now().year - 10),
                              label: "ပြန်ဆပ်သည့်ရက်စွဲ",
                              value: _selectedDate,
                              onChanged: (date) {
                                if (date != null) {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                }
                              },
                            ),

                            TextFormField(
                              controller: _remarkController,
                              enabled: !isLoading,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: "မှတ်ချက်",
                              ),
                            ),
                            SizedBox(height: 16),

                            /// note text or info text message that
                            /// if the amount is more than the due amount,
                            /// it will be adjusted to the due amount
                            /// or else the amount will be deducted from the interest first
                            /// then the principal
                            /// this is just an info message
                            Text(
                              "မှတ်ချက်: ပြန်ဆပ်ငွေပမာဏသည် အတိုးနှုန်းမှ ဦးစွာနှုပ်မည်ဖြစ်သည်။ ပိုမိုသောငွေပမာဏကို အရင်းမှ ထပ်နှုပ်မည်ဖြစ်သည်။",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer
                                        .withAlpha(200),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context
                                    .read<TransactionDetailCubit>()
                                    .createRepayment(
                                      Repayment(
                                        transactionId:
                                            state.transaction?.id ?? 0,
                                        amountPaid: double.parse(
                                          _amountController.text.trim(),
                                        ),
                                        paymentDate: _selectedDate,
                                        note: _remarkController.text.trim(),
                                      ),
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("အတည်ပြုမည်"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
