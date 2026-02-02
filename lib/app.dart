import 'package:chey_ngar/models/transactions.dart';
import 'package:chey_ngar/ui/screens/contacts_list_screen.dart';
import 'package:flutter/material.dart';
import 'ui/screens/transactions_list_screen.dart';
import 'ui/widgets/quick_calculator_screen.dart';

class CheyNgarApplication extends StatefulWidget {
  const CheyNgarApplication({super.key});

  @override
  State<CheyNgarApplication> createState() => _CheyNgarApplicationState();
}

class _CheyNgarApplicationState extends State<CheyNgarApplication> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('အချေးအငှား'), centerTitle: true),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                            // icon: Icons.attach_money,
                            icon: Icons.call_received_rounded,
                            // color: Colors.teal,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionsListScreen(
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // builder: (context) => const DashboardScreen(),
                                  builder: (context) =>
                                      const TransactionsListScreen(
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
                  SizedBox(height: 8),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ContactsListScreen(),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InterestSimulatorScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'အချေးအငှား အက်ပလီကေးရှင်းမှ ကြိုဆိုပါသည်',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'ဤအက်ပလီကေးရှင်းသည် သင့်၏ ငွေကြေးလိုအပ်ချက်များကို ဖြည့်ဆည်းရန် အချေးနှင့် အငှားဝန်ဆောင်မှုများကို ပံ့ပိုးပေးရန် ရည်ရွယ်ထားပါသည်။ ကျွန်ုပ်တို့၏ ဝန်ဆောင်မှုများကို အသုံးပြု၍ သင့်ဘဝကို ပိုမိုလွယ်ကူမြန်ဆန်လိုက်ပါ 💡',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        wordSpacing: 3,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Theme.of(context).canvasColor,
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Powered by ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    children: [
                      TextSpan(
                        text: 'JLP Group',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
