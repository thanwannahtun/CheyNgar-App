import 'package:flutter/material.dart';
import '../../services/email_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  int _selectedRating = 0; // 0 = not rated, 1-5 = star rating
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // Build feedback text with optional star rating
    final ratingText = _selectedRating > 0
        ? '${'⭐' * _selectedRating} ($_selectedRating/5)\n\n'
        : '';
    final fullFeedback = '$ratingText${_feedbackController.text.trim()}';

    final error = await EmailService.instance.sendFeedback(
      feedbackText: fullFeedback,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error == null) {
      // ── Success ──────────────────────────────────────────────────────────
      _feedbackController.clear();
      setState(() => _selectedRating = 0);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.favorite, color: Colors.pink, size: 48),
          title: const Text('ကျေးဇူးတင်ပါသည်! 🙏', textAlign: TextAlign.center),
          content: const Text(
            'သင့်အကြံပြုချက်သည် ကျွန်ုပ်တို့ အတွက် အလွန်တန်ဖိုးရှိပါသည်။\n'
            'Perfect English App ကို ပိုမိုကောင်းမွန်အောင် '
            'ကြိုးစားသွားမည်ဖြစ်ပါသည်။',
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('အကြံပြုချက် ✍️')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: hPad),
            children: [
              // ── Header ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: theme.colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'သင့်ရဲ့ ထင်မြင်ယူဆချက်တွေကို ကြားသိရဖို့ '
                        'စိတ်အားထက်သန်နေပါတယ်။ '
                        'အကြံဉာဏ်သစ်တွေဖြစ်ဖြစ်၊ '
                        'ကြုံတွေ့နေရတဲ့ အခက်အခဲတွေကို ဝေမျှပေးနိုင်ပါတယ်။',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Star Rating ───────────────────────────────────────────────
              const Text(
                'App ကို အဆင့်ပေးပါ (ရွေးချယ်နိုင်သည်)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() {
                      // Tap same star again to deselect
                      _selectedRating = _selectedRating == star ? 0 : star;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: star <= _selectedRating
                            ? Colors.amber
                            : Colors.grey,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),

              if (_selectedRating > 0) ...[
                const SizedBox(height: 4),
                Text(
                  _ratingLabel(_selectedRating),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Feedback text ─────────────────────────────────────────────
              TextFormField(
                controller: _feedbackController,
                maxLines: 7,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ဤနေရာတွင် အကြံပြုချက် ရေးသားပါ...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'အကြံပြုချက် ဖြည့်ပေးပါ';
                  }
                  if (v.trim().length < 5) {
                    return 'အနည်းဆုံး စာလုံး ၅ လုံး ရေးပေးပါ';
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
                    _isSending ? 'ပေးပို့နေသည်...' : 'အကြံပြုချက် ပေးပို့ရန်',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'သင့်အကြံပြုချက်များကို NaYa Myanmar ထံသာ ပေးပို့ပါမည်။',
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

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'မကြိုက်ပါ';
      case 2:
        return 'သာမန်';
      case 3:
        return 'အဆင်ပြေသည်';
      case 4:
        return 'ကောင်းသည်';
      case 5:
        return 'အလွန်ကောင်းသည်! 🎉';
      default:
        return '';
    }
  }
}
