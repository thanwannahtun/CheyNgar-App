import 'package:chey_ngar/models/transactions.dart';
import 'package:chey_ngar/ui/screens/contacts_list_screen.dart';
import 'package:flutter/material.dart';
import 'core/route_util/route_names.dart';
import 'core/widgets/confirm_exit_wrapper.dart';
import 'ui/screens/accounting_screen.dart';
import 'ui/screens/transactions_list_screen.dart';
import 'ui/widgets/app_drawer.dart';
import 'ui/widgets/quick_calculator_screen.dart';

class CheyNgarApplication extends StatefulWidget {
  const CheyNgarApplication({super.key});

  @override
  State<CheyNgarApplication> createState() => _CheyNgarApplicationState();
}

class _CheyNgarApplicationState extends State<CheyNgarApplication> {
  ConfirmExitWrapperState? _confirmExitState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _confirmExitState = ConfirmExitWrapper.of(context);
    _confirmExitState?.setCustomPopHandler(_handlePop);
  }

  @override
  void dispose() {
    _confirmExitState?.setCustomPopHandler(null);
    _confirmExitState = null;
    super.dispose();
  }

  bool _handlePop() {
    return false; // Already on DashboardScreen: allow confirm exit dialog to show
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'အချေးအငှား',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.profileAccount);
            },
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 50,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _reportCard(
                      context,
                      title: "ချေးယူထားသော ငွေ",
                      subtitle: "စုစုပေါင်း ချေးယူငွေ",
                      icon: Icons.call_received_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsListScreen(
                              direction: TransactionDirection.borrow,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _reportCard(
                      context,
                      title: "ချေးပေးထားသော ငွေ",
                      subtitle: "စုစုပေါင်း ချေးပေးငွေ",
                      icon: Icons.call_made_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsListScreen(
                              direction: TransactionDirection.lend,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _reportCard(
                      context,
                      title: "ချေးယူသူ/ချေးပေးသူများ",
                      subtitle: "ချေးယူသူများ/ချေးပေးသူများ စာရင်း",
                      icon: Icons.contacts,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _reportCard(
                      context,
                      title: "Quick Calculator",
                      subtitle: "အတိုးတွက်စက်",
                      icon: Icons.calculate_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InterestSimulatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Accounting & Double-Entry Ledger Card
            SizedBox(
              width: double.infinity,
              child: Card(
                child: _reportCard(
                  context,
                  title: "စာရင်းကိုင်နှင့် ဂျာနယ်",
                  subtitle:
                      "ဒက်ဘစ်/ခရက်ဒစ် စာရင်း၊ ဘဏ္ဍာရေး အနှစ်ချုပ်နှင့် အမြတ်/အရှုံး",
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountingScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
