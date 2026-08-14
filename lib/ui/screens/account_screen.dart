import 'package:chey_ngar/core/extensions/navigator_extension.dart';
import 'package:chey_ngar/ui/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../core/route_util/route_names.dart';
import '../../models/user.dart';
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
        title: const Text("My Profile"),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouteNames.settingScreen);
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog.adaptive(
                  title: const Text('Sign Out?'),
                  content: const Text('အကောင့်မှထွက်မည်မှာ သေချာပါသလား?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Cancel'),
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
                      child: const Text('Sign Out'),
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
                    message: state.message ?? "Something went wrong!",
                    onRetry: () => getUserInfo(),
                  ),
                );
              } else if (state.status == BlocStatus.success &&
                  state.currentUser != null) {
                return _buildProfileView(context, state.currentUser!);
              } else {
                return const Center(child: Text("No user data available"));
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
        CircleAvatar(
          radius: 50,
          // Display the first letter of the user's name if available, otherwise show a default icon , Upper case the first letter of the name
          child: Text(
            "🥸",
            style: const TextStyle(fontSize: 39, color: Colors.white),
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
            leading: const Icon(Icons.edit),
            title: const Text("ပင်နံပါတ် အသစ်ပြောင်းမည်"),
            onTap: () {},
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
            title: Text("Settings"),
            subtitle: Text("System settings"),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            onTap: () => context.pushNamed(RouteNames.settingScreen),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 16),

        PoweredByNaYa(),
      ],
    );
  }
}
