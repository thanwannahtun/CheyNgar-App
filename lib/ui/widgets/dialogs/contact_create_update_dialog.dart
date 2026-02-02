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

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameController.text = widget.initial!.name ?? '';
      _phoneController.text = widget.initial!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
              icon: Icon(Icons.close),
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
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      spacing: 16,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: "Contact Name",
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _phoneController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: "Contact Phone",
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Phone is required";
                            }
                            return null;
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
