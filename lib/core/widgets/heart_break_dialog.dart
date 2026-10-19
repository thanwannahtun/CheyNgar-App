import 'package:flutter/material.dart';

class HeartbreakDialog extends StatelessWidget {
  final String title;
  final String quote;
  final String stayText;
  final String exitText;
  final VoidCallback onExitConfirmed;

  const HeartbreakDialog({
    super.key,
    required this.title,
    required this.quote,
    required this.stayText,
    required this.exitText,
    required this.onExitConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog.adaptive(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Pyidaungsu",
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        '"$quote"',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 16,
          fontFamily: "Pyidaungsu",
          // Adapts gracefully: slightly brighter pink in dark mode for contrast
          color: isDark ? const Color(0xFFFF69B4) : const Color(0xFFD81B60),
        ),
      ),
      actions: [
        // CANCEL / STAY (TextButton: Safe & welcoming primary color)
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Pyidaungsu",
            ),
          ),
          child: Text(stayText),
        ),

        // CONFIRM / EXIT (FilledButton: Cold & destructive error container color)
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first
            onExitConfirmed(); // Fire the logout/exit callback
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
            textStyle: const TextStyle(
              fontFamily: "Pyidaungsu",
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
          ),
          child: Text(exitText),
        ),
      ],
    );
  }
}
