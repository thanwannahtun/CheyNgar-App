import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmExitWrapper extends StatefulWidget {
  final Widget child;

  const ConfirmExitWrapper({super.key, required this.child});

  static ConfirmExitWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<ConfirmExitWrapperState>();
  }

  @override
  State<ConfirmExitWrapper> createState() => ConfirmExitWrapperState();
}

class ConfirmExitWrapperState extends State<ConfirmExitWrapper> {
  FutureOr<bool> Function()? _customPopHandler;

  void setCustomPopHandler(FutureOr<bool> Function()? handler) {
    _customPopHandler = handler;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_customPopHandler != null) {
          final handled = await _customPopHandler!();
          if (handled) return;
        }

        if (!context.mounted) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Exit App"),
              content: Text(
                "တကယ် ထားရစ်ခဲ့တော့မှာလား အသည်းရယ် 🥹",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontFamily: "Pyidaungsu",
                  // Adapts gracefully: slightly brighter pink in dark mode for contrast
                  color: isDark
                      ? const Color(0xFFFF69B4)
                      : const Color(0xFFD81B60),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: "Pyidaungsu",
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("မခွဲနိုင်သေးဘူး 😭"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer,
                          foregroundColor: theme.colorScheme.onErrorContainer,
                          textStyle: const TextStyle(
                            fontFamily: "Pyidaungsu",
                            fontWeight: FontWeight.w500,
                          ),
                          elevation: 0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("သွားတော့မယ်"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );

        if (shouldExit == true) {
          SystemNavigator.pop(); // Closes the app
        }
      },
      child: widget.child,
    );
  }
}
