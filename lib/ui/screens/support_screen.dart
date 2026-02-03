import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support Us ❤️")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: ListView(
            children: [
              const Text(
                "ဒီအက်ပ်ကို အသုံးဝင်တယ်လို့ ခံစားရင် လှူဒါန်းပြီး ပံ့ပိုးနိုင်ပါတယ်။ ပိုမိုကောင်းမွန်တဲ့ လုပ်ဆောင်ချက်တွေ ဖန်တီးနိုင်ဖို့ သင့်ရဲ့ ပံ့ပိုးမှု လိုအပ်ပါတယ်။ ကျွန်ုပ်တို့ အမြဲကူညီပေးနေပါမယ်။ ❤️",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              _bankTile(
                context,
                Text("KBZ Pay", style: TextStyle(color: Colors.blue)),
                "09 123 456 789",
              ),
              _bankTile(
                context,
                Text("Wave Pay", style: TextStyle(color: Colors.yellowAccent)),
                "09 987 654 321",
              ),
              _bankTile(
                context,
                Text("AYA Bank", style: TextStyle(color: Colors.redAccent)),
                "1234567890",
              ),

              const SizedBox(height: 30),

              // optional QR section
              const Text(
                "Scan QR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("QR Code"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankTile(BuildContext context, Text title, String number) {
    return Card(
      child: ListTile(
        title: title,
        subtitle: Text(number),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: number));

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Copied")));
          },
        ),
      ),
    );
  }
}
