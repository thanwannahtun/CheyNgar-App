


import 'package:flutter/material.dart';

class AddContactPage extends StatelessWidget {
  final String title;
  const AddContactPage({super.key, required this.title});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: 'အမည်')),
            TextField(decoration: InputDecoration(labelText: 'ဖုန်းနံပါတ်')),
            SizedBox(height: 24),
            ElevatedButton(onPressed: null, child: Text('သိမ်းမည်')),
          ],
        ),
      ),
    );
  }
}