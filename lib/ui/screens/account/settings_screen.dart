import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/auth/auth_cubit.dart';
import '../../../bloc/theme_mode/theme_mode_cubit.dart';
import '../../../core/env.dart';
import 'delete_account_screen.dart';
import 'help_and_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('${Env.baseUrl}/legal/privacy-standards');
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('မဖွင့်နိုင်ပါ — ကွန်ရက်စစ်ဆေးပါ')),
        );
      }
    }
  }

  Future<void> _openTermsAndConditions(BuildContext context) async {
    final uri = Uri.parse('${Env.baseUrl}/legal/terms-and-policies');
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('မဖွင့်နိုင်ပါ — ကွန်ရက်စစ်ဆေးပါ')),
        );
      }
    }
  }

  Future<void> _openContactEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'nayatech.myanmar@gmail.com',
      query: 'subject=CheyNgar%20Support',
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('nayatech.myanmar@gmail.com')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isAuthenticated = context.watch<AuthCubit>().state.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('ဆက်တင်များ'), centerTitle: false),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: 8,
        ),
        children: [
          // ══════════════════════════════════════════
          // SECTION: Account & Legal
          // ══════════════════════════════════════════
          _SectionHeader(
            label: 'အကောင့်နှင့် ဥပဒေဆိုင်ရာ',
            cs: cs,
            theme: theme,
          ),

          _SettingsTile(
            icon: Icons.gavel_rounded,
            iconColor: cs.primary,
            title: 'သဘောတူညီချက်နှင့် မူဝါဒများ',
            subtitle: 'ဝန်ဆောင်မှုဆိုင်ရာ ကတိသစ္စာများ ဖတ်ရှုရန်',
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openTermsAndConditions(context),
          ),

          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            iconColor: cs.secondary,
            title: 'ကိုယ်ရေးလုံခြုံမှု မူဝါဒ',
            subtitle: 'ဒေတာ လုံခြုံရေးနှင့် ဥပဒေဆိုင်ရာ ထုတ်ပြန်ချက်',
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openPrivacyPolicy(context),
          ),

          const Divider(height: 24),

          // ══════════════════════════════════════════
          // SECTION: Appearance
          // ══════════════════════════════════════════
          _SectionHeader(label: 'အသွင်အပြင်', cs: cs, theme: theme),

          _ThemeModeTile(cs: cs, theme: theme),

          const Divider(height: 24),

          // ══════════════════════════════════════════
          // SECTION: Support
          // ══════════════════════════════════════════
          _SectionHeader(label: 'အကူအညီနှင့် ဆက်သွယ်ရန်', cs: cs, theme: theme),

          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: cs.tertiary,
            title: 'အကူအညီနှင့် ပံ့ပိုးမှု',
            subtitle: 'မေးခွန်းများ၊ ဘွတ်ကင်ပြဿနာများ',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpAndSupportScreen()),
            ),
          ),

          _SettingsTile(
            icon: Icons.email_outlined,
            iconColor: cs.tertiary,
            title: 'ဆက်သွယ်ရန်',
            subtitle: 'nayatech.myanmar@gmail.com',
            // subtitle: 'nayatech.myanmar@gmail.com',
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openContactEmail(context),
          ),

          const Divider(height: 24),

          // ══════════════════════════════════════════
          // SECTION: About
          // ══════════════════════════════════════════
          _SectionHeader(label: 'အပလီကေးရှင်းအကြောင်း', cs: cs, theme: theme),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: cs.outline,
            title: '"အချေးအငှား" application အကြောင်း',
            subtitle: 'အချေးအငှား (Lender & Borrower Management)',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'အချေးအငှား',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2026 အချေးအငှား — NaYa Myanmar\nAll rights reserved.',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'အချေးအငှား သည် မြန်မာနိုင်ငံ၏ အချေးအငှား (Lender & Borrower Management) system တစ်ခုဖြစ်သည်။',
                  ),
                ],
              );
            },
          ),

          _SettingsTile(
            icon: Icons.verified_rounded,
            iconColor: cs.outline,
            title: 'ဗားရှင်း',
            subtitle: '1.0.0 (build 1)',
            onTap: null,
          ),

          const Divider(height: 24),

          // ══════════════════════════════════════════
          // SECTION: Danger zone (authenticated only)
          // ══════════════════════════════════════════
          if (isAuthenticated) ...[
            _SectionHeader(
              label: 'အန္တရာယ်ရှိသောဆောင်ရွက်ချက်',
              cs: cs,
              theme: theme,
              isWarning: true,
            ),

            _SettingsTile(
              icon: Icons.person_remove_rounded,
              iconColor: cs.error,
              title: 'အကောင့်ဖျက်သိမ်းမည်',
              subtitle: 'ဤဆောင်ရွက်ချက်ကို နောက်ပြန်ဆုတ်၍ မရပါ',
              trailing: Icon(Icons.chevron_right_rounded, color: cs.error),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
              ),
            ),

            const SizedBox(height: 8),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Reusable section header
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.cs,
    required this.theme,
    this.isWarning = false,
  });
  final String label;
  final ColorScheme cs;
  final ThemeData theme;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          // color: isWarning ? cs.error : cs.primary,
          color: Colors.blue[300],
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Reusable tile
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: cs.outlineVariant)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Theme Mode Toggle tile
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.cs, required this.theme});

  final ColorScheme cs;
  final ThemeData theme;

  String _label(ThemeMode m) => switch (m) {
    ThemeMode.system => 'system',
    ThemeMode.light => 'အလင်း',
    ThemeMode.dark => 'အမှောင်',
  };

  @override
  Widget build(BuildContext context) {
    // BlocBuilder ကိုသုံးပြီး ThemeModeCubit ရဲ့ state (ThemeMode) အပြောင်းအလဲကို စောင့်ကြည့်မယ်
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, currentThemeMode) {
        return Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : currentThemeMode == ThemeMode.light
                    ? Icons.light_mode_rounded
                    : Icons.brightness_auto_rounded,
                size: 20,
                color: cs.onPrimaryContainer,
              ),
            ),
            title: const Text(
              'အပလီကေးရှင်း အပြင်အဆင်',
            ), // အပလီကေးရှင်း Theme ကို မြန်မာလို ပိုသဘာဝကျအောင် ပြောင်းထားပါတယ်
            subtitle: Text(_label(currentThemeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              onChanged: (val) {
                if (val == null) return;
                // Dropdown ရွေးလိုက်တာနဲ့ Cubit ရဲ့ toggleTheme ကိုလှမ်းခေါ်ပြီး State ရော Storage ပါ Update လုပ်မယ်
                context.read<ThemeModeCubit>().toggleTheme(val);
              },
              items: ThemeMode.values.where((m) => m != ThemeMode.system).map((
                m,
              ) {
                return DropdownMenuItem(value: m, child: Text(_label(m)));
              }).toList(),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
