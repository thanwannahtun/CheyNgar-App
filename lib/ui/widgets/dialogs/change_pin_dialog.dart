import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/extensions/navigator_extension.dart';

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();

    if (currentPin == newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN နံပါတ်အသစ်သည် လက်ရှိ PIN နှင့် မတူညီသင့်ပါ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await context.read<AuthCubit>().changePin(
          currentPin: currentPin,
          newPin: newPin,
        );

    if (mounted) {
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN နံပါတ် အသစ် အောင်မြင်စွာ ပြောင်းလဲပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg = context.read<AuthCubit>().state.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg ?? 'PIN ပြောင်းလဲရာတွင် အမှားဖြစ်ပွားပါသည်'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.changePinStatus == BlocStatus.loading;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "PIN အသစ်ပြောင်းမည်",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "လုံခြုံရေးအတွက် လက်ရှိ PIN နံပါတ်နှင့် PIN အသစ်ကို ထည့်သွင်းပေးပါ",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Current PIN
                    TextFormField(
                      controller: _currentPinController,
                      enabled: !isLoading,
                      obscureText: _obscureCurrent,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: "လက်ရှိ PIN နံပါတ် *",
                        hintText: "••••",
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscureCurrent = !_obscureCurrent);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "လက်ရှိ PIN နံပါတ် ထည့်သွင်းပေးပါ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // New PIN
                    TextFormField(
                      controller: _newPinController,
                      enabled: !isLoading,
                      obscureText: _obscureNew,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: "PIN နံပါတ်အသစ် (အနည်းဆုံး ၄ လုံး) *",
                        hintText: "••••",
                        prefixIcon: const Icon(Icons.password_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscureNew = !_obscureNew);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "PIN နံပါတ်အသစ် ထည့်သွင်းပေးပါ";
                        }
                        if (val.trim().length < 4) {
                          return "PIN အသစ်သည် အနည်းဆုံး ၄ လုံး ဖြစ်ရပါမည်";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirm New PIN
                    TextFormField(
                      controller: _confirmPinController,
                      enabled: !isLoading,
                      obscureText: _obscureConfirm,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: "PIN နံပါတ်အသစ် အတည်ပြုပါ *",
                        hintText: "••••",
                        prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "PIN နံပါတ်အသစ်ကို ထပ်မံရိုက်ထည့်ပေးပါ";
                        }
                        if (val.trim() != _newPinController.text.trim()) {
                          return "PIN နံပါတ်အသစ်နှင့် တူညီမှု မရှိပါ";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: const Text("မလုပ်တော့ပါ"),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("ပြောင်းလဲမည်"),
            ),
          ],
        );
      },
    );
  }
}
