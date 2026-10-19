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
              widget.initial != null
                  ? "လူစာရင်း အချက်အလက်ပြင်ရန်"
                  : "လူသစ်ထည့်ရန်",
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
                            labelText: "အမည် / နာမည် *",
                            hintText: "လူအမည် ထည့်ပါ",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "အမည် ထည့်သွင်းပေးပါ";
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
                            labelText: "ဖုန်းနံပါတ် *",
                            hintText: "09xxxxxxxxx",
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "ဖုန်းနံပါတ် ထည့်သွင်းပေးပါ";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nrcController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: "မှတ်ပုံတင်အမှတ် (မထည့်လည်းရပါသည်)",
                            hintText: "၁၂/ဥကတ(နိုင်)xxxxxx",
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          enabled: !isLoading,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "နေရပ်လိပ်စာ (မထည့်လည်းရပါသည်)",
                            hintText: "အိမ်အမှတ်၊ လမ်း၊ မြို့နယ်",
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _contactType,
                          decoration: const InputDecoration(
                            labelText: "စာရင်းအမျိုးအစား",
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Manual',
                              child: Text("ကိုယ်တိုင်ထည့်သွင်းမှု"),
                            ),
                            DropdownMenuItem(
                              value: 'Google',
                              child: Text("Google အဆက်အသွယ်"),
                            ),
                            DropdownMenuItem(
                              value: 'Internal',
                              child: Text("အက်ပ်အတွင်းစာရင်း"),
                            ),
                            DropdownMenuItem(
                              value: 'Imported',
                              child: Text("ဖိုင်မှသွင်းထားမှု"),
                            ),
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
              : const Text("ဖျက်မည်", style: TextStyle(color: Colors.red)),
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
            : const Text("သိမ်းမည်"),
      ),
    ];
  }
}
