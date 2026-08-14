import '../../../core/extensions/navigator_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../models/contact.dart';

class ContactCreateUpdateDialog extends StatefulWidget {
  final Contact? initial;
  const ContactCreateUpdateDialog({super.key, this.initial});

  @override
  State<ContactCreateUpdateDialog> createState() =>
      _ContactCreateUpdateDialogState();
}

class _ContactCreateUpdateDialogState extends State<ContactCreateUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nrcController = TextEditingController();
  final _addressController = TextEditingController();
  String _contactType = 'Manual';

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameController.text = widget.initial!.name ?? '';
      _phoneController.text = widget.initial!.phone ?? '';
      _nrcController.text = widget.initial!.nrc ?? '';
      _addressController.text = widget.initial!.address ?? '';
      _contactType = widget.initial!.contactType ?? 'Manual';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nrcController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactsCubit, ContactsState>(
      listenWhen: (prev, curr) => prev.crudStatus != curr.crudStatus,
      listener: (context, state) {
        if (state.crudStatus == BlocStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.crudStatus == BlocStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? "Something went wrong")),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.crudStatus == BlocStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.initial != null ? "Edit Contact" : "New Contact",
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
            ),
            actions: _buildActions(isLoading, context),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: 24,
            ),
            child: Card(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: "Contact Name *",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Contact Phone *",
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Phone is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nrcController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: "NRC / ID (Optional)",
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          enabled: !isLoading,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Address (Optional)",
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _contactType,
                          decoration: const InputDecoration(
                            labelText: "Contact Type",
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Manual', child: Text("Manual")),
                            DropdownMenuItem(value: 'Google', child: Text("Google")),
                            DropdownMenuItem(value: 'Internal', child: Text("Internal")),
                            DropdownMenuItem(value: 'Imported', child: Text("Imported")),
                          ],
                          onChanged: isLoading
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _contactType = val);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions(bool isLoading, BuildContext context) {
    return [
      if (widget.initial != null)
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () => context.read<ContactsCubit>().deleteContact(
                  widget.initial?.id ?? 0,
                ),
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_formKey.currentState?.validate() ?? false) {
                  final contact = Contact(
                    id: widget.initial?.id,
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    nrc: _nrcController.text.trim().isNotEmpty
                        ? _nrcController.text.trim()
                        : null,
                    address: _addressController.text.trim().isNotEmpty
                        ? _addressController.text.trim()
                        : null,
                    contactType: _contactType,
                  );
                  if (widget.initial == null) {
                    context.read<ContactsCubit>().createContact(contact);
                  } else {
                    context.read<ContactsCubit>().updateContact(contact);
                  }
                }
              },
        child: isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Save"),
      ),
    ];
  }
}
