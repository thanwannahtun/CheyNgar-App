import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/extensions/navigator_extension.dart';
import '../../../models/contact.dart';
import '../../../services/contacts_sync_service.dart';

enum ImportExportTab { importTab, exportTab }

class ContactsImportExportDialog extends StatefulWidget {
  final ImportExportTab initialTab;

  const ContactsImportExportDialog({
    super.key,
    this.initialTab = ImportExportTab.exportTab,
  });

  @override
  State<ContactsImportExportDialog> createState() =>
      _ContactsImportExportDialogState();
}

class _ContactsImportExportDialogState extends State<ContactsImportExportDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _importTextController = TextEditingController();
  String _exportFormat = 'CSV'; // 'CSV' or 'JSON'
  String _exportText = '';
  List<ClassifiedContact> _parsedContacts = [];
  String _mergeStrategy = 'skip';
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == ImportExportTab.importTab ? 0 : 1,
    );
    _generateExportText();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importTextController.dispose();
    super.dispose();
  }

  void _generateExportText() {
    final contacts = context.read<ContactsCubit>().state.contacts ?? [];
    if (_exportFormat == 'CSV') {
      _exportText = ContactsSyncService.exportToCsv(contacts);
    } else {
      _exportText = ContactsSyncService.exportToJson(contacts);
    }
    setState(() {});
  }

  void _parseImportText() {
    final text = _importTextController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedContacts = [];
        _parseError = null;
      });
      return;
    }

    try {
      List<Contact> contacts;
      if (text.startsWith('[') || text.startsWith('{')) {
        contacts = ContactsSyncService.parseJsonContacts(text);
      } else {
        contacts = ContactsSyncService.parseCsvContacts(text);
      }

      if (contacts.isEmpty) {
        setState(() {
          _parsedContacts = [];
          _parseError = "No valid contact rows could be parsed.";
        });
        return;
      }

      final existing = context.read<ContactsCubit>().state.contacts ?? [];
      final classified = ContactsSyncService.classifyContacts(
        incomingContacts: contacts,
        existingContacts: existing,
      );

      setState(() {
        _parsedContacts = classified;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _parsedContacts = [];
        _parseError = "Parsing error: ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
  }

  Future<void> _performImport() async {
    final selected = _parsedContacts
        .where((c) => c.isSelected)
        .map((c) => c.contact)
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact to import')),
      );
      return;
    }

    final result = await context.read<ContactsCubit>().batchImportContacts(
      selected,
      mergeStrategy: _mergeStrategy,
    );

    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${result['importedCount'] ?? 0} contacts (${result['updatedCount'] ?? 0} updated, ${result['skippedCount'] ?? 0} skipped)',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final isImporting = state.crudStatus == BlocStatus.loading;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              children: [
                // Header with Tabs
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.sim_card_download), text: "Import Contacts"),
                    Tab(icon: Icon(Icons.upload_file_rounded), text: "Export Contacts"),
                  ],
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildImportTab(isImporting),
                      _buildExportTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportTab(bool isImporting) {
    final selectedCount = _parsedContacts.where((c) => c.isSelected).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Paste CSV or JSON contact data below:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.paste, size: 16),
                label: const Text("Paste Clipboard", style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _importTextController.text = data!.text!;
                    _parseImportText();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _importTextController,
            maxLines: 4,
            onChanged: (_) => _parseImportText(),
            decoration: InputDecoration(
              hintText: "Name,Phone,NRC,Address\nAung Aung,0912345678,12/...,Yangon\n...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          if (_parseError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _parseError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),

          // Duplicate Action & Summary
          if (_parsedContacts.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  "Parsed ${_parsedContacts.length} contacts ($selectedCount selected)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _mergeStrategy,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'skip', child: Text("Skip Duplicates", style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'overwrite', child: Text("Update Duplicates", style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _mergeStrategy = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  itemCount: _parsedContacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _parsedContacts[index];
                    return CheckboxListTile(
                      dense: true,
                      value: item.isSelected,
                      onChanged: (val) {
                        setState(() => item.isSelected = val ?? false);
                      },
                      title: Text(item.contact.name ?? 'Unnamed', style: const TextStyle(fontSize: 13)),
                      subtitle: Text(item.contact.phone ?? '-', style: const TextStyle(fontSize: 12)),
                      secondary: item.matchStatus == ContactMatchStatus.exactPhoneMatch
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("Duplicate", style: TextStyle(fontSize: 10, color: Colors.orange.shade900)),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("New", style: TextStyle(fontSize: 10, color: Colors.green.shade900)),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            const Spacer(),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isImporting ? null : () => context.pop(),
                child: const Text("Close"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (selectedCount == 0 || isImporting) ? null : _performImport,
                child: isImporting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Import Selected ($selectedCount)"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    final contactsCount = context.read<ContactsCubit>().state.contacts?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                "Export $contactsCount Contacts",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'CSV', label: Text('CSV')),
                  ButtonSegment(value: 'JSON', label: Text('JSON')),
                ],
                selected: {_exportFormat},
                onSelectionChanged: (set) {
                  setState(() {
                    _exportFormat = set.first;
                    _generateExportText();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: _exportText),
              readOnly: true,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Close"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text("Copy to Clipboard"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _exportText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contacts copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
