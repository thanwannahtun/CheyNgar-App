import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contacts/contacts_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/extensions/navigator_extension.dart';
import '../../../services/contacts_sync_service.dart';

class GoogleContactsImportScreen extends StatefulWidget {
  const GoogleContactsImportScreen({super.key});

  @override
  State<GoogleContactsImportScreen> createState() => _GoogleContactsImportScreenState();
}

class _GoogleContactsImportScreenState extends State<GoogleContactsImportScreen> {
  bool _isLoading = true;
  bool _permissionDenied = false;
  String? _errorMessage;
  List<ClassifiedContact> _classifiedList = [];
  List<ClassifiedContact> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  String _mergeStrategy = 'skip'; // 'skip' or 'overwrite'
  String _filterType = 'ALL'; // 'ALL', 'NEW', 'IN_CONTACTS'

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
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredList = _classifiedList.where((item) {
        final name = (item.contact.name ?? '').toLowerCase();
        final phone = (item.contact.phone ?? '').toLowerCase();
        final matchesQuery = query.isEmpty || name.contains(query) || phone.contains(query);

        if (!matchesQuery) return false;

        if (_filterType == 'NEW') {
          return item.matchStatus == ContactMatchStatus.newContact;
        } else if (_filterType == 'IN_CONTACTS') {
          return item.matchStatus == ContactMatchStatus.exactPhoneMatch ||
              item.matchStatus == ContactMatchStatus.nameOnlyMatch;
        }
        return true;
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
            'Imported ${result['importedCount'] ?? 0} contacts (${result['updatedCount'] ?? 0} updated, ${result['skippedCount'] ?? 0} skipped)',
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
    final selectedCount = _classifiedList.where((c) => c.isSelected).length;
    final totalCount = _classifiedList.length;
    final newCount = _classifiedList.where((c) => c.matchStatus == ContactMatchStatus.newContact).length;
    final inContactsCount = _classifiedList.where((c) => c.matchStatus != ContactMatchStatus.newContact).length;

    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final isImporting = state.crudStatus == BlocStatus.loading;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: isImporting ? null : () => context.pop(),
            ),
            title: const Text(
              "Import from Google Contacts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (!_isLoading && !_permissionDenied && _errorMessage == null)
                TextButton(
                  onPressed: _loadDeviceContacts,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 18),
                      SizedBox(width: 4),
                      Text("Reload"),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading contacts from Google / Device..."),
                    ],
                  ),
                )
              : _permissionDenied
                  ? _buildPermissionDeniedView()
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _buildMainContent(totalCount, newCount, inContactsCount),
          bottomNavigationBar: (!_isLoading && !_permissionDenied && _errorMessage == null)
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$selectedCount of $totalCount selected",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                _mergeStrategy == 'skip' ? "Skip duplicates" : "Update duplicates",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: (selectedCount == 0 || isImporting) ? null : _importSelected,
                          icon: isImporting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            isImporting ? "Importing..." : "Import ($selectedCount)",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMainContent(int totalCount, int newCount, int inContactsCount) {
    return Column(
      children: [
        // Top Card: Summary & Duplicate Action
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(90),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatCard("Total Device", totalCount.toString(), Colors.blue, 'ALL'),
                  const SizedBox(width: 8),
                  _buildStatCard("New Contacts", newCount.toString(), Colors.green, 'NEW'),
                  const SizedBox(width: 8),
                  _buildStatCard("In Contacts", inContactsCount.toString(), Colors.orange, 'IN_CONTACTS'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Duplicate Action:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: DropdownButton<String>(
                        isDense: true,
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: _mergeStrategy,
                        items: const [
                          DropdownMenuItem(
                            value: 'skip',
                            child: Text(
                              "Skip Existing Contacts",
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'overwrite',
                            child: Text(
                              "Update/Merge Existing Contacts",
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _mergeStrategy = val);
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

        // Search bar & Selection Toggles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: "Search name or phone...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () => _toggleSelectAll(true),
                child: const Text("Select All", style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () => _toggleSelectAll(false),
                child: const Text("None", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        const Divider(height: 8),

        // List
        Expanded(
          child: _filteredList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          "No contacts match your criteria",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredList[index];
                    final contact = item.contact;
                    final initial = _getInitial(contact.name);

                    return CheckboxListTile(
                      value: item.isSelected,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                          const SizedBox(width: 6),
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
                        radius: 18,
                        child: Text(
                          initial,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, Color color, String filterKey) {
    final isSelected = _filterType == filterKey;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _filterType = filterKey;
            _applyFilters();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(40) : color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withAlpha(70),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
}
