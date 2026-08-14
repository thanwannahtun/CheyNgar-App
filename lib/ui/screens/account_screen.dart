import 'package:chey_ngar/core/extensions/navigator_extension.dart';
import 'package:chey_ngar/ui/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../core/route_util/route_names.dart';
import '../../models/user.dart';
import '../widgets/dialogs/change_pin_dialog.dart';
import '../widgets/powered_by_naya.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  getUserInfo() async {
    context.read<AuthCubit>().getProfile();
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ကျွန်ုပ်၏ ပရိုဖိုင်"),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            tooltip: 'ဆက်တင်များ',
            onPressed: () {
              context.pushNamed(RouteNames.settingScreen);
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            tooltip: 'အကောင့်မှ ထွက်မည်',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog.adaptive(
                  title: const Text('အကောင့်မှ ထွက်မည်လား?'),
                  content: const Text('အကောင့်မှထွက်မည်မှာ သေချာပါသလား?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('မထွက်ပါ'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        context.read<AuthCubit>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.loginScreen,
                          (route) => false,
                        );
                      },
                      child: const Text('ထွက်မည်'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, AuthState state) {
              if (state.status == BlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == BlocStatus.failure) {
                return Center(
                  child: ErrorMessage(
                    message: state.message ?? "အချက်အလက် ရယူရာတွင် အမှားဖြစ်ပွားခဲ့ပါသည်",
                    onRetry: () => getUserInfo(),
                  ),
                );
              } else if (state.status == BlocStatus.success &&
                  state.currentUser != null) {
                return _buildProfileView(context, state.currentUser!);
              } else {
                return const Center(child: Text("အသုံးပြုသူ အချက်အလက် မရှိပါ"));
              }
            },
          ),
        ),
      ),
    );
  }

  ListView _buildProfileView(BuildContext context, User user) {
    return ListView(
      children: [
        const CircleAvatar(
          radius: 50,
          child: Text(
            "🥸",
            style: TextStyle(fontSize: 39, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name ?? "",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            user.phoneNumber ?? "",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text("ပင်နံပါတ် အသစ်ပြောင်းမည်"),
            subtitle: const Text("လုံခြုံရေး PIN နံပါတ် အသစ်လဲလှယ်ရန်"),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const ChangePinDialog(),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text("ဆက်တင်များ"),
            subtitle: const Text("စနစ်ဆိုင်ရာ ဆက်တင်များနှင့် မူဝါဒများ"),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            onTap: () => context.pushNamed(RouteNames.settingScreen),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const PoweredByNaYa(),
      ],
    );
  }
}
