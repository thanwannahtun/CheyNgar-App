import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/extensions/navigator_extension.dart';
import '../../../models/contact.dart';
import '../../../services/contacts_sync_service.dart';

enum ImportExportInitialTab { importTab, exportTab }

class ContactsImportExportScreen extends StatefulWidget {
  final ImportExportInitialTab initialTab;

  const ContactsImportExportScreen({
    super.key,
    this.initialTab = ImportExportInitialTab.exportTab,
  });

  @override
  State<ContactsImportExportScreen> createState() =>
      _ContactsImportExportScreenState();
}

class _ContactsImportExportScreenState extends State<ContactsImportExportScreen>
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
      initialIndex: widget.initialTab == ImportExportInitialTab.importTab
          ? 0
          : 1,
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
          _parseError = "ဖော်မတ်မှန်ကန်သော လူစာရင်း မတွေ့ရှိပါ။";
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
        _parseError =
            "ဖိုင်ဖတ်ရာတွင် အမှားဖြစ်ပွားပါသည်: ${e.toString().replaceAll('Exception: ', '')}";
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
        const SnackBar(
          content: Text('ကျေးဇူးပြု၍ အနည်းဆုံး လူစာရင်းတစ်ခု ရွေးချယ်ပေးပါ'),
        ),
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
            'စာရင်းသစ် ${result['importedCount'] ?? 0} ခု ထည့်သွင်းပြီးပါပြီ (${result['updatedCount'] ?? 0} ခု ပြင်ဆင်ပြီး၊ ${result['skippedCount'] ?? 0} ခု ကျော်ခဲ့သည်)',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      context.pop();
    }
  }

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final trimmed = name.trim();
    if (trimmed.characters.isEmpty) return '?';
    return trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final isImporting = state.crudStatus == BlocStatus.loading;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: isImporting ? null : () => context.pop(),
            ),
            title: const Text("လူစာရင်း ထည့်သွင်းခြင်းနှင့် ထုတ်ယူခြင်း"),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.sim_card_download),
                  text: "စာရင်းသွင်းရန် (Import)",
                ),
                Tab(
                  icon: Icon(Icons.upload_file_rounded),
                  text: "စာရင်းထုတ်ယူရန် (Export)",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildImportTab(isImporting), _buildExportTab()],
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
                  "CSV သို့မဟုတ် JSON ဖော်မတ်ဖြင့် စာရင်းထည့်သွင်းရန်:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.paste, size: 16),
                label: const Text(
                  "Clipboard မှ ကူးထည့်မည်",
                  style: TextStyle(fontSize: 12),
                ),
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
              hintText:
                  "အမည်,ဖုန်းနံပါတ်,မှတ်ပုံတင်,လိပ်စာ\nဦးအောင်,0912345678,၁၂/...,ရန်ကုန်\n...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
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
                Expanded(
                  child: Text(
                    "တွေ့ရှိသော စာရင်း ${_parsedContacts.length} ခု ($selectedCount ခု ရွေးထားသည်)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<String>(
                    value: _mergeStrategy,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'skip',
                        child: Text(
                          "ရှိပြီးသားကို ကျော်မည်",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'overwrite',
                        child: Text(
                          "ရှိပြီးသားကို ပြင်ဆင်မည်",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _mergeStrategy = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  itemCount: _parsedContacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _parsedContacts[index];
                    final initial = _getInitial(item.contact.name);

                    return CheckboxListTile(
                      dense: true,
                      value: item.isSelected,
                      onChanged: (val) {
                        setState(() => item.isSelected = val ?? false);
                      },
                      title: Text(
                        item.contact.name ?? 'အမည်မရှိ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        item.contact.phone ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                      secondary: CircleAvatar(
                        radius: 16,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                child: const Text("ပိတ်မည်"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (selectedCount == 0 || isImporting)
                      ? null
                      : _performImport,
                  icon: isImporting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    isImporting
                        ? "ထည့်သွင်းနေပါသည်..."
                        : "($selectedCount) စာရင်းသွင်းမည်",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    final contactsCount =
        context.read<ContactsCubit>().state.contacts?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "စုစုပေါင်း လူစာရင်း ($contactsCount) ယောက် ထုတ်ယူရန်",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                child: const Text("ပိတ်မည်"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text(
                    "Clipboard သို့ ကူးယူမည်",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _exportText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'လူစာရင်းများကို Clipboard သို့ ကူးယူပြီးပါပြီ!',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
