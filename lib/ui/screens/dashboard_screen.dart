import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('အချေးအငှား (Dashboard)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                _buildStatCard("ရရန်ရှိ (Lend)", "၁,၅၀၀,၀၀၀", Colors.teal),
                const SizedBox(width: 12),
                _buildStatCard(
                  "ပေးရန်ရှိ (Borrow)",
                  "၅၀၀,၀၀၀",
                  Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("မကြာမီပေးဆပ်ရန်ရှိသူများ"),
            const SizedBox(height: 12),
            // Mocked List
            _buildUpcomingItem(
              "U Ba",
              "၁၀၀,၀၀၀ MMK",
              "2 days left",
              Colors.teal,
            ),
            _buildUpcomingItem("Daw Hla", "၅၀,၀၀၀ MMK", "Today", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingItem(
    String name,
    String amount,
    String due,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(name[0]),
        ),
        title: Text(name),
        subtitle: Text("Due: $due"),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text("အားလုံးကြည့်ရန်")),
      ],
    );
  }
}
