import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  // Helper function to launch URLs
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Green Theme Colors
    const primaryGreen = Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Lottie.asset('assets/lottie/customer_support.json', height: 300),
            const SizedBox(height: 24),

            // Email Section
            _buildContactTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'nayatech.myanmar@gmail.com',
              onTap: () => _launchURL(
                'mailto:nayatech.myanmar@gmail.com?subject=RMS Support Request',
              ),
              color: primaryGreen,
            ),

            // Phone Section (Call + Auto-Copy)
            _buildContactTile(
              icon: Icons.phone_in_talk_outlined,
              label: 'Phone',
              value: '+95 9 449 206 487',
              onTap: () async {
                // Try to call
                await _launchURL('tel:+959449206487');
                // Also copy to clipboard just in case
                await Clipboard.setData(
                  const ClipboardData(text: "+959449206487"),
                );
              },
              color: primaryGreen,
            ),

            const SizedBox(height: 16),

            // Website Section
            InkWell(
              onTap: () => _launchURL('https://rmsmyanmar.site'),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Visit our website:\nhttps://rmsmyanmar.site',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
