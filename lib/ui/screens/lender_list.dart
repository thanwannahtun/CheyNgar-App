// People you lent money to

import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import 'add_contact_page.dart';
import 'history_page.dart';
import 'repayment_operation_screen.dart';
import 'transaction_page.dart';

class LenderList extends StatefulWidget {
  const LenderList({super.key});

  @override
  State<LenderList> createState() => _LenderListState();
}

class _LenderListState extends State<LenderList> {
  int _totalFor(String personId) {
    return transactions
        .where((t) => t.personId == personId)
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ချေးပေးသူများ'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.attach_money_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RepaymentOperationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.person_add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddContactPage(title: 'ချေးပေးသူ ထည့်မည်'),
              ),
            );
          },
        ),
        body: ListView.builder(
          itemCount: lenders.length,
          itemBuilder: (context, index) {
            final p = lenders[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p.name),
                subtitle: Text('စုစုပေါင်း: ${_totalFor(p.id)} Ks'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('ချေးပေး'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionPage(
                          person: p,
                          type: TransactionType.lend,
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
