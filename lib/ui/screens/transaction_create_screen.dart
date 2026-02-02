import 'package:chey_ngar/models/transactions.dart';

import '../../../core/extensions/navigator_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../bloc/transactions/transactions_cubit.dart';
import '../../core/controller_record.dart';
import '../../models/contact.dart';
import '../widgets/dialogs/contact_selection_dialog.dart';
import '../widgets/input_fields/date_picker.dart';
import '../widgets/input_fields/input_form.dart';

class TransactionCreateScreen extends StatefulWidget {
  const TransactionCreateScreen({super.key, required this.direction});

  final TransactionDirection direction;
  @override
  State<TransactionCreateScreen> createState() =>
      _TransactionCreateScreenState();
}

class _TransactionCreateScreenState extends State<TransactionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _interestRateController;
  late final TextEditingController _remarkController;
  late DateTime _selectedDate;
  late DateTime _dueDate;

  final _contactControllerRecord = ControllerRecord<Contact>(
    controller: TextEditingController(),
    model: null,
  );

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _interestRateController = TextEditingController();
    _remarkController = TextEditingController();
    _selectedDate = DateTime.now();
    _dueDate = _selectedDate.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestRateController.dispose();
    _remarkController.dispose();
    _contactControllerRecord.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listenWhen: (prev, curr) => prev.crudStatus != curr.crudStatus,
      listener: (context, state) {
        if (state.crudStatus == BlocStatus.success) {
          Navigator.of(context).pop();
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
            title: Text("New Transaction"),
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
            child: Column(
              children: [
                Expanded(
                  child: Card(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.6,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            spacing: 16,
                            children: [
                              InputForm(
                                label:
                                    widget.direction ==
                                        TransactionDirection.borrow
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
                                        initialValue:
                                            _contactControllerRecord.model,
                                        onSelected: (value) {
                                          setState(() {
                                            _contactControllerRecord
                                                    .controller
                                                    .text =
                                                value.name ?? '-';
                                            _contactControllerRecord.model =
                                                value;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // amount number only
                              TextFormField(
                                controller: _amountController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "ချေးငွေပမာဏ",
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return "ချေးငွေပမာဏ ထည့်ပါ";
                                  }
                                  if (double.tryParse(val.trim()) == null) {
                                    return "ချေးငွေပမာဏ မှန်ကန်မှုမရှိပါ";
                                  }
                                  return null;
                                },
                              ),
                              // interest rate decimal only (%) max 100 min 0.00
                              TextFormField(
                                controller: _interestRateController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "အတိုးနှုန်း (%)",
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return "အတိုးနှုန်း ထည့်ပါ";
                                  }
                                  final rate = double.tryParse(val.trim());
                                  if (rate == null ||
                                      rate < 0.0 ||
                                      rate > 100.0) {
                                    return "အတိုးနှုန်း မှန်ကန်မှုမရှိပါ";
                                  }
                                  return null;
                                },
                              ),
                              // date only picker
                              DatePickerFormField(
                                label: "ချေးသည့်ရက်စွဲ",
                                value: _selectedDate,
                                onChanged: (date) {
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                              ),
                              // due date picker
                              DatePickerFormField(
                                label: "ပေးဆပ်ရမည့်ရက်စွဲ",
                                value: _dueDate,
                                validateionEnabled: false,
                                onChanged: (date) {
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date;
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
                            ],
                          ),
                        ),
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
                                  .read<TransactionsCubit>()
                                  .createTransaction(
                                    Transaction(
                                      contactId:
                                          _contactControllerRecord.model?.id,
                                      initialPrincipal: double.parse(
                                        _amountController.text.trim(),
                                      ),
                                      interestRate: double.parse(
                                        _interestRateController.text.trim(),
                                      ),
                                      startDate: _selectedDate,
                                      remark: _remarkController.text.trim(),
                                      direction: widget.direction,
                                      dueDate: _dueDate,
                                      interestType: InterestType.monthly,
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
                        : const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
