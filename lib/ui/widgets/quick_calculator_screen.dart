import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InterestSimulatorScreen extends StatefulWidget {
  const InterestSimulatorScreen({super.key});

  @override
  State<InterestSimulatorScreen> createState() =>
      _InterestSimulatorScreenState();
}

class _InterestSimulatorScreenState extends State<InterestSimulatorScreen> {
  // Input Controllers
  final _amountController = TextEditingController(text: "1000000");
  final _rateController = TextEditingController(text: "5.0");

  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // --- CALCULATION LOGIC ---
    double principal = double.tryParse(_amountController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;

    // 1. Calculate Day Difference
    int diffDays = endDate.difference(startDate).inDays;
    if (diffDays < 0) diffDays = 0;

    // 2. Myanmar 30-day Month Logic
    // Formula: (Principal * Rate%) / 30 * Days
    double accruedInterest = (principal * (rate / 100) / 30) * diffDays;
    double totalPayable = principal + accruedInterest;

    return Scaffold(
      appBar: AppBar(title: const Text('အတိုးတွက်စက် (Quick Calc)')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            // 1. Input Fields
            _buildInputField(
              "ကျန်ရှိသောအရင်း (Remaining Amount)",
              _amountController,
              Icons.money,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              "အတိုးနှုန်း % (Interest Rate)",
              _rateController,
              Icons.percent,
            ),

            const SizedBox(height: 25),

            // 2. Date Pickers
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    "စတင်သည့်ရက်",
                    startDate,
                    (date) => setState(() => startDate = date),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDatePicker(
                    "ပေးဆပ်မည့်ရက်",
                    endDate,
                    (date) => setState(() => endDate = date),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 3. Result Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _resultRow("ရက်ပေါင်း (Total Days)", "$diffDays ရက်"),
                  const Divider(),
                  _resultRow(
                    "ကျသင့်အတိုး (Interest)",
                    "${_format(accruedInterest)} MMK",
                  ),
                  const SizedBox(height: 10),
                  _resultRow(
                    "စုစုပေါင်း (Total)",
                    "${_format(totalPayable)} MMK",
                    isLarge: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "* တွက်ချက်မှုမှာ တစ်လလျှင် ရက် ၃၀ စံနှုန်းဖြင့် ဖြစ်ပါသည်",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  String _format(double val) => NumberFormat("#,###.##").format(val);

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(DateFormat('dd/MM/yyyy').format(date))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultRow(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: isLarge ? 16 : 14),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: isLarge ? 16 : 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
