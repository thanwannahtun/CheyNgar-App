import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';

import '../../../core/bloc_utils/bloc_status.dart';
import '../../../models/contact.dart';

class ContactSelectionDialog extends StatefulWidget {
  const ContactSelectionDialog({
    super.key,
    required this.onSelected,
    this.initialValue,
  });

  final ValueChanged<Contact> onSelected;
  final Contact? initialValue;

  @override
  State<ContactSelectionDialog> createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<ContactSelectionDialog> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
        vertical: 8,
      ),
      child: Column(
        spacing: 8,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text("Select Contact"),
            ],
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search by Name..',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {
              searchQuery = value.trim().toLowerCase();
            }),
          ),
          Expanded(
            child: BlocBuilder<ContactsCubit, ContactsState>(
              builder: (context, state) {
                if (state.status == BlocStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == BlocStatus.failure) {
                  return Center(
                    child: Text(state.message ?? 'Something went wrong'),
                  );
                }

                final contacts = state.contacts ?? [];

                final filteredTrips = contacts.where((contact) {
                  return contact.name?.toLowerCase().contains(searchQuery) ??
                      false;
                }).toList();

                if (filteredTrips.isEmpty) {
                  return const Center(child: Text("No trips found."));
                }

                return ListView.separated(
                  itemCount: filteredTrips.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = filteredTrips[index];
                    final isSelected = widget.initialValue?.id == contact.id;

                    return ListTile(
                      title: Text(contact.name ?? "-"),
                      subtitle: Text(contact.phone ?? "-"),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        widget.onSelected(contact);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
