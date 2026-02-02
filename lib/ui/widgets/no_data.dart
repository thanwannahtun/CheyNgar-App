import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/extensions/widget_extension.dart';

import '../../core/platform.dart';

class NoData extends StatelessWidget {
  const NoData({super.key, required this.message, this.actionBtn});

  final String message;
  final Widget? actionBtn;

  @override
  Widget build(BuildContext context) {
    final isMobile = PlatformType.isMobile(context);
    final isTablet = PlatformType.isTablet(context);

    if (isMobile || isTablet) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Lottie.asset(
              'assets/lottie/no-data.json',
              height: MediaQuery.of(context).size.width * 0.9,
            ).expanded(),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (actionBtn != null) actionBtn!,
          ],
        ),
      );
    } else {
      return Center(
        child: Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Lottie.asset('assets/lottie/no-data.json')),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (actionBtn != null) actionBtn!,
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
