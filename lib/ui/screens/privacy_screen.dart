import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ကိုယ်ရေးအချက်အလက် လုံခြုံမှုမူဝါဒ 🔒")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: ListView(
            children: const [
              Text(
                "လူကြီးမင်းတို့၏ ကိုယ်ရေးအချက်အလက် လုံခြုံမှုသည် ကျွန်ုပ်တို့အတွက် အလွန်အရေးကြီးပါသည်။ သင်၏ သဘောတူညီချက်မပါဘဲ မည်သည့်အချက်အလက်ကိုမျှ မျှဝေခြင်း ပြုလုပ်မည်မဟုတ်ပါ။ ကောက်ယူရရှိထားသော အချက်အလက်များကို စနစ်တကျ သိမ်းဆည်းထားပြီး App အသုံးပြုမှု ပိုမိုကောင်းမွန်လာစေရန်အတွက်သာ အသုံးပြုပါမည်။",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "အသေးစိတ် ထပ်မံသိရှိလိုပါက အချိန်မရွေး ဆက်သွယ်မေးမြန်းနိုင်ပါသည်။",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
