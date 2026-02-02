// People you borrowed money from
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import 'add_contact_page.dart';
import 'history_page.dart';
import 'transaction_page.dart';

class BorrowerList extends StatefulWidget {
  const BorrowerList({super.key});

  @override
  State<BorrowerList> createState() => _BorrowerListState();
}

class _BorrowerListState extends State<BorrowerList> {
  int _totalFor(String personId) {
    return transactions
        .where((t) => t.personId == personId)
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('ချေးယူသူများ'), centerTitle: true),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.person_add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddContactPage(title: 'ချေးယူသူ ထည့်မည်'),
              ),
            );
          },
        ),
        body: ListView.builder(
          itemCount: borrowers.length,
          itemBuilder: (context, index) {
            final p = borrowers[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p.name),
                subtitle: Text('စုစုပေါင်း: ${_totalFor(p.id)} Ks'),
                trailing: ElevatedButton(
                  child: const Text('ချေးယူ'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionPage(
                          person: p,
                          type: TransactionType.borrow,
                        ),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryPage(person: p)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
