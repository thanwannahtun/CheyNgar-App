import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../models/transaction_model.dart';

class HistoryPage extends StatelessWidget {
  final Person person;
  const HistoryPage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final personTx = transactions
        .where((t) => t.personId == person.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('${person.name} မှတ်တမ်း'), centerTitle: true),
      body: ListView.builder(
        itemCount: personTx.length,
        itemBuilder: (context, index) {
          final t = personTx[index];
          return ListTile(
            leading: Icon(
              t.type == TransactionType.borrow
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            title: Text('${t.amount} Ks'),
            subtitle: Text(t.note),
            trailing: Text('${t.date.day}/${t.date.month}/${t.date.year}'),
          );
        },
      ),
    );
  }
}
