import 'package:flutter/material.dart';

class RepaymentOperationScreen extends StatefulWidget {
  const RepaymentOperationScreen({super.key});

  @override
  State<RepaymentOperationScreen> createState() =>
      _RepaymentOperationScreenState();
}

class _RepaymentOperationScreenState extends State<RepaymentOperationScreen> {
  double amountInput = 0;
  double interestDue = 15000; // Mocked

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double principalPortion = amountInput > interestDue
        ? amountInput - interestDue
        : 0;
    double interestPortion = amountInput > interestDue
        ? interestDue
        : amountInput;

    return Scaffold(
      appBar: AppBar(title: const Text("အကြွေးဆပ်ရန်")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 24,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "ပေးဆပ်မည့်ပမာဏ",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => amountInput = double.tryParse(val) ?? 0),
            ),
            // Waterfall Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _rowDetail(
                    "အတိုးအတွက်နှုတ်ယူမှု",
                    interestPortion.toString(),
                    Colors.blue,
                  ),
                  const Divider(),
                  _rowDetail(
                    "အရင်းမှနှုတ်ယူမှု",
                    principalPortion.toString(),
                    Colors.green,
                  ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "မှတ်ချက်",
                // border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => amountInput = double.tryParse(val) ?? 0),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("အတည်ပြုသည်"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
