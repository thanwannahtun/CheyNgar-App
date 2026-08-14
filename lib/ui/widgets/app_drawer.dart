import 'package:chey_ngar/core/extensions/navigator_extension.dart';
import 'package:chey_ngar/core/route_util/route_names.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // SizedBox(height: 10),

          ///
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[800],
              image: DecorationImage(
                image: AssetImage('assets/images/cheyngar.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: SizedBox(),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'အချေးအငှား အက်ပလီကေးရှင်း',
              textAlign: TextAlign.start,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ),
          // Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'ဤအက်ပလီကေးရှင်းသည် သင့်၏ ငွေကြေးလိုအပ်ချက်များကို ဖြည့်ဆည်းရန် အချေးနှင့် အငှားဝန်ဆောင်မှုများကို ပံ့ပိုးပေးရန် ရည်ရွယ်ထားပါသည်။ ကျွန်ုပ်တို့၏ ဝန်ဆောင်မှုများကို အသုံးပြု၍ သင့်ဘဝကို ပိုမိုလွယ်ကူမြန်ဆန်လိုက်ပါ 💡',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 14,
                wordSpacing: 3,
                height: 1.5,
              ),
            ),
          ),
          Divider(),

          ...List.generate(destinations.length, (index) {
            final dest = destinations[index];
            // final isSelected = index == widget.selectedDestinationIndex;
            final isSelected = false;
            return ListTile(
              leading: Icon(
                dest.icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                dest.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              selected: isSelected,
              iconColor: Theme.of(context).colorScheme.primary,
              focusColor: Theme.of(context).colorScheme.primaryContainer,
              selectedColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(dest.routeName);
              },
              selectedTileColor: Theme.of(context).colorScheme.onSecondary,
            );
          }),
        ],
      ),
    );
  }
}

class Destination {
  const Destination(
    this.icon,
    this.label,
    this.selectedIcon, {
    required this.routeName,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String routeName;
}

const List<Destination> destinations = <Destination>[
  Destination(
    Icons.feedback_outlined,
    'Feedback',
    Icons.feedback_rounded,
    routeName: RouteNames.feedback,
  ),
  Destination(
    Icons.app_shortcut_outlined,
    'Need Custom App',
    Icons.app_shortcut_rounded,
    routeName: RouteNames.needCustomApp,
  ),
];
