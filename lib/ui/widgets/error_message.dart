import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/extensions/widget_extension.dart';

import '../../core/platform.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final isMobile = PlatformType.isMobile(context);
    final isTablet = PlatformType.isTablet(context);
    if (isMobile || isTablet) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/not-found.json',
                height: width * 0.5,
                fit: BoxFit.contain,
                width: width,
              ).expanded(flex: 5),

              Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              if (onRetry != null)
                SizedBox(
                  width: width * 0.5,
                  child: ListTile(
                    title: TextButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        textStyle: const TextStyle(
                          fontFamily: "Pyidaungsu",
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 0,
                      ),
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "ပြန်လည်ကြိုးစားမည်",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).expanded(),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Lottie.asset('assets/lottie/not-found.json')),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (onRetry != null)
                      SizedBox(
                        width: width * 0.5,
                        child: TextButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                            textStyle: const TextStyle(
                              fontFamily: "Pyidaungsu",
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 0,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "ပြန်လည်ကြိုးစားမည်",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
