import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../models/transaction_model.dart';

class TransactionPage extends StatelessWidget {
  final Person person;
  final TransactionType type;

  const TransactionPage({super.key, required this.person, required this.type});

  @override
  Widget build(BuildContext context) {
    final isBorrow = type == TransactionType.borrow;
    return Scaffold(
      appBar: AppBar(
        title: Text(isBorrow ? 'ငွေ ချေးယူမည်' : 'ငွေ ချေးပေးမည်'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'အမည်: ${person.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'ငွေပမာဏ')),
            const TextField(decoration: InputDecoration(labelText: 'မှတ်ချက်')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('သိမ်းမည်')),
          ],
        ),
      ),
    );
  }
}
