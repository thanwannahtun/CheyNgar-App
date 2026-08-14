import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth_cubit.dart';
import '../../../core/route_util/route_names.dart';

/// Full-featured account deletion screen with:
/// - Complete Burmese legal disclosure (GDPR-aligned data retention policy)
/// - 3-step confirmation gate: read → checkbox → type "ဖျက်မည်"
/// - Hooks into AuthCubit.deleteAccount()
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final ScrollController _scroll = ScrollController();
  bool _scrolledToBottom = false;
  bool _checkboxConfirmed = false;
  final _confirmController = TextEditingController();
  bool _typeConfirmed = false;
  bool _isLoading = false;

  static const _requiredPhrase = 'ဖျက်မည်';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _confirmController.addListener(() {
      final matches = _confirmController.text.trim() == _requiredPhrase;
      if (matches != _typeConfirmed) setState(() => _typeConfirmed = matches);
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrolledToBottom) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 40) {
      setState(() => _scrolledToBottom = true);
    }
  }

  bool get _canDelete =>
      _scrolledToBottom && _checkboxConfirmed && _typeConfirmed;

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthCubit>().deleteAccount();
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အမှားဖြစ်ပွားသည်: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: cs.primary, size: 48),
        title: const Text('အကောင့်ဖျက်ပြီးပါပြီ'),
        content: const Text(
          'သင့်အကောင့်နှင့် ကိုယ်ရေးအချက်အလက်များကို ဖျက်သိမ်းပြီးပါပြီ။\n\n'
          'ဥပဒေဆိုင်ရာ လိုအပ်ချက်ကြောင့် ချိတ်ဆက်ထားသော ဘွတ်ကင်မှတ်တမ်းများ၊ '
          'ငွေကြေးဆိုင်ရာ မှတ်တမ်းများကိုသာ လိုအပ်သောကာလ ဆက်လက်သိမ်းဆည်းမည်ဖြစ်ပြီး '
          'ပြတ်သားသော ကိုယ်ရေးအချက်အလက်နှင့် ချိတ်ဆက်မည် မဟုတ်ပါ။',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.app,
                (_) => false,
              );
            },
            child: const Text('အိုကေ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('အကောင့်ဖျက်သိမ်းရန်'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: cs.error),
                  const SizedBox(height: 16),
                  const Text('ဖျက်သိမ်းနေသည်…'),
                ],
              ),
            )
          : Column(
              children: [
                // ── Progress hint
                if (!_scrolledToBottom)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: cs.errorContainer,
                    child: Row(
                      children: [
                        Icon(
                          Icons.swipe_down_rounded,
                          size: 16,
                          color: cs.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'မူဝါဒများ ဖတ်ရှုပြီးမှ ဆက်လုပ်နိုင်မည်',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Scrollable policy content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: cs.errorContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    size: 44,
                                    color: cs.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'အကောင့်ဖျက်သိမ်းခြင်း မူဝါဒ',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ဆောင်ရွက်မည်မဟုတ်က ဤစာမျက်နှာမှ ထွက်ပါ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Warning banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.errorContainer,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cs.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚠️ ဤဆောင်ရွက်ချက်ကို နောက်ပြန်မဆုတ်နိုင်ပါ',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: cs.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'အကောင့်ဖျက်လိုက်ပြီးသည်နှင့် ၃၀ ရက်အတွင်း ပြန်လည်ရယူ၍ မရနိုင်ပါ။',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onErrorContainer,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 1: What will be deleted
                          _PolicySection(
                            theme: theme,
                            cs: cs,
                            icon: Icons.delete_forever_rounded,
                            iconBg: cs.errorContainer,
                            iconFg: cs.onErrorContainer,
                            title: '၁။ ဖျက်ပစ်မည့် အချက်အလက်များ',
                            items: const [
                              'ပရိုဖိုင်းအချက်အလက် — အမည်၊ email၊ ဖုန်းနံပါတ်',
                              'Password hash (လျှို့ဝှက်နံပါတ် hash)',
                              'Google OAuth ချိတ်ဆက်မှု token',
                              'Notification preferences နှင့် ဆက်တင်များ',
                              'App အတွင်း သိမ်းဆည်းထားသော Session data',
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section 2: What is retained (key legal section)
                          _PolicySection(
                            theme: theme,
                            cs: cs,
                            icon: Icons.storage_rounded,
                            iconBg: cs.secondaryContainer,
                            iconFg: cs.onSecondaryContainer,
                            title:
                                '၂။ ဆက်လက်သိမ်းဆည်းမည့် အချက်အလက်များ (ဥပဒေဆိုင်ရာ)',
                            items: const [
                              'သင့်၏ မှတ်တမ်းများ(Your Data) — ဤမှတ်တမ်းများသည် system ၏ကျန်မှတ်တမ်းများ၊ သုံးစွဲသူများနှင့် ချိတ်ဆက်နေသဖြင့် သင်တစ်ဦးတည်း ဆုံးဖြတ်၍ မဖျက်ပေး နိုင်ပါ',
                              'ငွေကြေးမှတ်တမ်းများ — မြန်မာနိုင်ငံ ကုမ္ပဏီဥပဒေ၊ နိုင်ငံတကာ AML/CTF ဥပဒေ အရ ငွေကြေးသွင်းမှတ်တမ်းများကို အနည်းဆုံး ၇ နှစ် သိမ်းဆည်းရမည် ဖြစ်သည်',
                              'စနစ်စစ်ဆေးရေး မှတ်တမ်းများ (Audit logs) — ၃ နှစ်ကြာ',
                              'ကိုယ်ပိုင်မသက်ဆိုင်သော ကိန်းဂဏန်းဆိုင်ရာ ဒေတာ (Anonymized analytics)',
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Legal note callout
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.balance_rounded,
                                  size: 20,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'ဤမူဝါဒသည် နိုင်ငံတကာ ကိုယ်ရေးလုံခြုံမှုမူဝါဒများ (GDPR Principle 5(1)(e) — Storage Limitation) နှင့် ကိုက်ညီသည်။ ဥပဒေဆိုင်ရာ တာဝန်ကျေသည့် ကာလထက် ပိုမိုသိမ်းဆည်းမည် မဟုတ်ပါ။ ဆက်လက်သိမ်းဆည်းသောဒေတာများကို သင်၏ ကိုယ်ရေးအချက်အလက်နှင့် ပြတ်သားစွာ ခွဲထုတ်ထားမည်ဖြစ်သည်။',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Section 3: Google OAuth
                          _PolicySection(
                            theme: theme,
                            cs: cs,
                            icon: Icons.link_off_rounded,
                            iconBg: cs.tertiaryContainer,
                            iconFg: cs.onTertiaryContainer,
                            title: '၃။ တတိယပါတီ (Google OAuth)',
                            items: const [
                              'CheyNgar (အချေးအငှား) အကောင့်ဖျက်ခြင်းဖြင့် Google ၏ OAuth token အလိုအလျောက် ဖျက်ပစ်မည် မဟုတ်ပါ',
                              'Google Account → Security → Third-party apps မှ "CheyNgar" ကို ရုပ်သိမ်းပါ',
                              'ကျွန်ုပ်တို့ Google မှ ထပ်မံဝင်ရောက်ကြည့်ရှုမည် မဟုတ်ပါ',
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section 4: Rights
                          _PolicySection(
                            theme: theme,
                            cs: cs,
                            icon: Icons.verified_user_rounded,
                            iconBg: cs.primaryContainer,
                            iconFg: cs.onPrimaryContainer,
                            title: '၄။ သင့်အခွင့်အရေးများ',
                            items: const [
                              'ဖျက်ခြင်းမပြုမီ သင့်ဒေတာ၏ မိတ္တူကို တောင်းဆိုနိုင်သည် — nayatech.myanmar@gmail.com',
                              'ဒေတာ စစ်ဆေးခွင့် (Right of Access) — သင့်ဒေတာ မည်သို့ အသုံးပြုကြောင်း မေးမြန်းနိုင်သည်',
                              'ဘတ်ကင်ဆိုင်ရာ ငြင်းဆန်မှု (Right to Object) — ဥပဒေဆိုင်ရာ ဒေတာသိမ်းမှုကို ငြင်းဆန်ရန် ကျွန်ုပ်တို့နှင့် ဆက်သွယ်နိုင်သည်',
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section 5: Contact
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '၅။ ဆက်သွယ်ရန်',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Data Protection: nayatech.myanmar@gmail.com\nAddress: BookBookmm.com, မန္တလေးမြို့, မြန်မာနိုင်ငံ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          Center(
                            child: Text(
                              '— မူဝါဒ စာမျက်နှာ အဆုံး —',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.outline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Bottom confirmation area
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 2: Checkbox
                      CheckboxListTile(
                        value: _checkboxConfirmed,
                        onChanged: _scrolledToBottom
                            ? (v) => setState(
                                () => _checkboxConfirmed = v ?? false,
                              )
                            : null,
                        title: Text(
                          'ဖော်ပြပါ မူဝါဒများကို ဖတ်ရှုနားလည်ပြီး အကောင့်ဖျက်ခြင်းကို သဘောတူပါသည်',
                          style: theme.textTheme.bodySmall,
                        ),
                        activeColor: cs.error,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 12),

                      // Step 3: Type-to-confirm
                      Text(
                        '"$_requiredPhrase" ဟု ရိုက်ထည့်ပါ',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _checkboxConfirmed ? cs.onSurface : cs.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmController,
                        enabled: _checkboxConfirmed,
                        decoration: InputDecoration(
                          hintText: 'ဖျက်မည်',
                          filled: true,
                          fillColor: cs.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.error, width: 2),
                          ),
                          suffixIcon: _typeConfirmed
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: cs.primary,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delete button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('မဖျက်တော့ပါ'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              key: const Key('delete_account_confirm_btn'),
                              onPressed: _canDelete ? _deleteAccount : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: cs.error,
                                foregroundColor: cs.onError,
                                disabledBackgroundColor: cs.error.withValues(
                                  alpha: 0.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'အကောင့်ဖျက်မည်',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Reusable policy section with bulleted list
class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.theme,
    required this.cs,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.items,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: iconFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
