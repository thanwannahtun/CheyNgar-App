import 'package:flutter/material.dart';

import '../../services/email_service.dart';

class NeedCustomAppScreen extends StatefulWidget {
  const NeedCustomAppScreen({super.key});

  @override
  State<NeedCustomAppScreen> createState() => _NeedCustomAppScreenState();
}

class _NeedCustomAppScreenState extends State<NeedCustomAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _requirementController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final error = await EmailService.instance.sendCustomAppRequest(
      fromName: _nameController.text.trim(),
      fromEmail: _emailController.text.trim(),
      requirements: _requirementController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error == null) {
      // ── Success ──────────────────────────────────────────────────────────
      _nameController.clear();
      _emailController.clear();
      _requirementController.clear();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text(
            'ပေးပို့မှု အောင်မြင်ပါသည်!',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'သင့်တောင်းဆိုမှုကို ကျွန်ုပ်တို့ထံ ရောက်ရှိပြီးပါပြီ။\n'
            'မကြာမီ ပြန်လည်ဆက်သွယ်ပေးပါမည်။',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // ── Error ─────────────────────────────────────────────────────────────
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ပေးပို့မှု မအောင်မြင်ပါ။ ကျေးဇူးပြု၍ ထပ်မံကြိုးစားပါ။\n($error)',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'ထပ်ကြိုး',
            textColor: Colors.white,
            onPressed: _submit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(title: const Text('စိတ်ကြိုက် Application အပ်နှံရန် 💼')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: hPad),
            children: [
              // ── Header card ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'သင့်လုပ်ငန်းအတွက် စိတ်ကြိုက် Application တစ်ခု '
                        'ဖန်တီးချင်ပါသလား? '
                        'အောက်ပါအချက်အလက်များကို ဖြည့်စွက်ပေးပါ။ '
                        'ကျွန်ုပ်တို့ဘက်မှ ပြန်လည်ဆက်သွယ်ပေးပါမည်။',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Name field ────────────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'အမည် *',
                  hintText: 'သင့်အမည် ထည့်ပါ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'အမည် ဖြည့်ပေးပါ';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Email field ───────────────────────────────────────────────
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'အီးမေး အကောင့် *',
                  hintText: 'example@gmail.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'အီးမေး ဖြည့်ပေးပါ';
                  if (!RegExp(
                    r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(v.trim())) {
                    return 'အီးမေး format မှားနေသည်';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Requirements field ────────────────────────────────────────
              TextFormField(
                controller: _requirementController,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'သင့်လိုအပ်ချက်များကို ဖော်ပြပေးပါ *',
                  hintText: 'ဥပမာ - ကိုယ်ပိုင် app တစ်ခု ဖန်တီးလိုသည်...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'လိုအပ်ချက်များ ဖြည့်ပေးပါ';
                  }
                  if (v.trim().length < 10) {
                    return 'အနည်းဆုံး စာလုံး ၁၀ လုံး ရေးပေးပါ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Submit button ─────────────────────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSending ? 'ပေးပို့နေသည်...' : 'တောင်းဆိုမှု ပေးပို့ရန်',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Info note ─────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'သင့်အချက်အလက်များကို လုံခြုံစွာ ကာကွယ်ထားပြီး '
                      'NaYa Myanmar ထံသို့သာ ပေးပို့ပါမည်။',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
