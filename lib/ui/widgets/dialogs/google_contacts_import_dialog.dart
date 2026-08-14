import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/extensions/navigator_extension.dart';
import '../../../services/contacts_sync_service.dart';

class GoogleContactsImportDialog extends StatefulWidget {
  const GoogleContactsImportDialog({super.key});

  @override
  State<GoogleContactsImportDialog> createState() => _GoogleContactsImportDialogState();
}

class _GoogleContactsImportDialogState extends State<GoogleContactsImportDialog> {
  bool _isLoading = true;
  bool _permissionDenied = false;
  String? _errorMessage;
  List<ClassifiedContact> _classifiedList = [];
  List<ClassifiedContact> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  String _mergeStrategy = 'skip'; // 'skip' or 'overwrite'

  @override
  void initState() {
    super.initState();
    _loadDeviceContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
      _errorMessage = null;
    });

    try {
      final existingContacts = context.read<ContactsCubit>().state.contacts ?? [];
      final deviceContacts = await ContactsSyncService.fetchDeviceContacts();

      final classified = ContactsSyncService.classifyContacts(
        incomingContacts: deviceContacts,
        existingContacts: existingContacts,
      );

      setState(() {
        _classifiedList = classified;
        _filteredList = classified;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _permissionDenied = e.toString().toLowerCase().contains('permission');
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _filterContacts(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredList = _classifiedList;
      });
      return;
    }
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredList = _classifiedList.where((item) {
        final name = (item.contact.name ?? '').toLowerCase();
        final phone = (item.contact.phone ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    });
  }

  void _toggleSelectAll(bool select) {
    setState(() {
      for (final item in _filteredList) {
        item.isSelected = select;
      }
    });
  }

  Future<void> _importSelected() async {
    final selected = _classifiedList
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
            'Imported ${result['importedCount'] ?? 0} new contacts (${result['updatedCount'] ?? 0} updated, ${result['skippedCount'] ?? 0} skipped)',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _classifiedList.where((c) => c.isSelected).length;
    final totalCount = _classifiedList.length;
    final newCount = _classifiedList.where((c) => c.matchStatus == ContactMatchStatus.newContact).length;
    final exactDupCount = _classifiedList.where((c) => c.matchStatus == ContactMatchStatus.exactPhoneMatch).length;

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                  child: Row(
                    children: [
                      Icon(Icons.contact_page_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Import from Google Contacts",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: isImporting ? null : () => context.pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Body content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text("Loading contacts from device..."),
                            ],
                          ),
                        )
                      : _permissionDenied
                          ? _buildPermissionDeniedView()
                          : _errorMessage != null
                              ? _buildErrorView()
                              : _buildContactsList(totalCount, newCount, exactDupCount),
                ),

                const Divider(height: 1),

                // Footer Actions
                if (!_isLoading && !_permissionDenied && _errorMessage == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$selectedCount of $totalCount selected",
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: isImporting ? null : () => context.pop(),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: (selectedCount == 0 || isImporting) ? null : _importSelected,
                              child: isImporting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text("Import ($selectedCount)"),
                            ),
                          ],
                        ),
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

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_accounts_outlined, size: 64, color: Colors.orange.shade600),
            const SizedBox(height: 16),
            const Text(
              "Contacts Permission Required",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "To import contacts from Google or your device, please grant contacts permission in your device settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDeviceContacts,
              icon: const Icon(Icons.refresh),
              label: const Text("Request Permission Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "Failed to load contacts",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeviceContacts,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(int totalCount, int newCount, int exactDupCount) {
    return Column(
      children: [
        // Summary Cards & Merge Strategy
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatBadge("Total", totalCount.toString(), Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatBadge("New", newCount.toString(), Colors.green),
                  const SizedBox(width: 8),
                  _buildStatBadge("Already in App", exactDupCount.toString(), Colors.orange),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Duplicate Action: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        isDense: true,
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: _mergeStrategy,
                        items: const [
                          DropdownMenuItem(
                            value: 'skip',
                            child: Text("Skip Existing Contacts", style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'overwrite',
                            child: Text("Update/Merge Existing Contacts", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _mergeStrategy = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search and Select All row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterContacts,
                  decoration: InputDecoration(
                    hintText: "Search device contacts...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _toggleSelectAll(true),
                child: const Text("All", style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: () => _toggleSelectAll(false),
                child: const Text("None", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Contacts List
        Expanded(
          child: _filteredList.isEmpty
              ? Center(
                  child: Text(
                    "No contacts match your filter",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredList[index];
                    final contact = item.contact;
                    return CheckboxListTile(
                      value: item.isSelected,
                      dense: true,
                      onChanged: (val) {
                        setState(() {
                          item.isSelected = val ?? false;
                        });
                      },
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name ?? 'Unnamed',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildMatchBadge(item.matchStatus),
                        ],
                      ),
                      subtitle: Text(
                        contact.phone ?? 'No phone number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      secondary: CircleAvatar(
                        radius: 16,
                        child: Text(
                          (contact.name != null && contact.name!.isNotEmpty)
                              ? contact.name!.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchBadge(ContactMatchStatus status) {
    switch (status) {
      case ContactMatchStatus.exactPhoneMatch:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Text(
            "In Contacts",
            style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.w500),
          ),
        );
      case ContactMatchStatus.nameOnlyMatch:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: Text(
            "Name Match",
            style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
          ),
        );
      case ContactMatchStatus.newContact:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Text(
            "New",
            style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w500),
          ),
        );
    }
  }
}
