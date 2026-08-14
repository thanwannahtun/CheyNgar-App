import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PoweredByNaYa extends StatefulWidget {
  final Color? textColor;
  final double fontSize;

  const PoweredByNaYa({
    super.key,
    this.textColor = Colors.grey,
    this.fontSize = 14.0,
  });

  @override
  State<PoweredByNaYa> createState() => _PoweredByNaYaState();
}

class _PoweredByNaYaState extends State<PoweredByNaYa> {
  // Define the recognizer here
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    // Initialize the recognizer
    _tapRecognizer = TapGestureRecognizer()..onTap = _handlePress;
  }

  @override
  void dispose() {
    // CRITICAL: Always dispose to prevent memory leaks
    _tapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    final Uri url = Uri.parse('https://nayamyanmar.com');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      alignment: Alignment.center, // Keeps it centered in footers
      child: RichText(
        text: TextSpan(
          text: 'Powered by ',
          style: TextStyle(
            color: widget.textColor,
            fontStyle: FontStyle.italic,
            fontSize: widget.fontSize,
            fontFamily: 'Inter', // Ensuring your brand font
          ),
          children: [
            TextSpan(
              text: 'NaYa Myanmar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
              recognizer: _tapRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}
