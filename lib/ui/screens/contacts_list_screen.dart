import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/platform.dart';
import '../../bloc/contacts/contacts_cubit.dart';
import '../../models/contact.dart';
import '../widgets/dialogs/contact_create_update_dialog.dart';
import 'contacts_import_export_screen.dart';
import 'google_contacts_import_screen.dart';
import '../widgets/error_message.dart';
import '../widgets/loading.dart';
import '../widgets/no_data.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().fetchContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final trimmed = name.trim();
    if (trimmed.characters.isEmpty) return '?';
    return trimmed.characters.first;
  }

  List<Contact> _filterContacts(List<Contact> allContacts) {
    final query = _searchController.text.trim().toLowerCase();

    return allContacts.where((contact) {
      final name = (contact.name ?? '').toLowerCase();
      final phone = (contact.phone ?? '').toLowerCase();
      final nrc = (contact.nrc ?? '').toLowerCase();
      final address = (contact.address ?? '').toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          phone.contains(query) ||
          nrc.contains(query) ||
          address.contains(query);

      if (!matchesQuery) return false;

      if (_selectedTypeFilter != 'ALL') {
        final type = (contact.contactType ?? 'Manual').toUpperCase();
        if (type != _selectedTypeFilter.toUpperCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Map<String, int> _calculateCounts(List<Contact> contacts) {
    final counts = <String, int>{
      'ALL': contacts.length,
      'MANUAL': 0,
      'GOOGLE': 0,
      'INTERNAL': 0,
      'IMPORTED': 0,
    };

    for (final c in contacts) {
      final type = (c.contactType ?? 'Manual').toUpperCase();
      if (counts.containsKey(type)) {
        counts[type] = (counts[type] ?? 0) + 1;
      } else {
        counts['MANUAL'] = (counts['MANUAL'] ?? 0) + 1;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => const ContactCreateUpdateDialog(),
          );
        },
        tooltip: "New Contact",
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Contacts"),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: "Sync & Refresh",
            onPressed: () {
              context.read<ContactsCubit>().fetchContacts(isRefresh: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing contacts...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_outlined),
            onSelected: (value) async {
              if (value == 'import-from-gcontacts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const GoogleContactsImportScreen(),
                  ),
                );
              } else if (value == 'import-contacts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const ContactsImportExportScreen(
                      initialTab: ImportExportInitialTab.importTab,
                    ),
                  ),
                );
              } else if (value == 'export-contacts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const ContactsImportExportScreen(
                      initialTab: ImportExportInitialTab.exportTab,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "import-contacts",
                child: Row(
                  children: [
                    Icon(
                      Icons.sim_card_download,
                      color: Colors.green,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Import Contacts'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: "export-contacts",
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Export Contacts'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'import-from-gcontacts',
                child: Row(
                  children: [
                    Icon(
                      Icons.contact_page_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Import via Google Contacts'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          if (state.status == BlocStatus.initial ||
              state.status == BlocStatus.loading) {
            return const Loading();
          }

          if (state.status == BlocStatus.failure) {
            return ErrorMessage(
              message: state.message ?? "❌Error!",
              onRetry: () {
                context.read<ContactsCubit>().fetchContacts();
              },
            );
          }

          final allContacts = state.contacts ?? [];
          if (allContacts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<ContactsCubit>().fetchContacts(isRefresh: true),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: NoData(message: "No Contacts")),
                ],
              ),
            );
          }

          final filteredContacts = _filterContacts(allContacts);
          final counts = _calculateCounts(allContacts);

          int crossAxisCount = 3;
          double childAspectRatio = 8 / 3;
          final width = MediaQuery.of(context).size.width;

          if (width <= PlatformType.mobile.minWidth) {
            crossAxisCount = 1;
            childAspectRatio = 7 / 2;
          } else if (width <= PlatformType.tablet.minWidth) {
            crossAxisCount = 2;
            childAspectRatio = 7 / 3;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search by name, phone, NRC...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All', counts['ALL'] ?? 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('MANUAL', 'Manual', counts['MANUAL'] ?? 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('GOOGLE', 'Google', counts['GOOGLE'] ?? 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('INTERNAL', 'Internal', counts['INTERNAL'] ?? 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('IMPORTED', 'Imported', counts['IMPORTED'] ?? 0),
                  ],
                ),
              ),

              // Results Count Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Showing ${filteredContacts.length} of ${allContacts.length} contacts",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty || _selectedTypeFilter != 'ALL')
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _selectedTypeFilter = 'ALL';
                          });
                        },
                        child: const Text(
                          "Reset filters",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 8),

              // Contacts Grid / List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ContactsCubit>().fetchContacts(isRefresh: true),
                  child: filteredContacts.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  const Text("No matching contacts found"),
                                ],
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: MediaQuery.of(context).size.width * 0.04,
                          ),
                          itemCount: filteredContacts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            final initial = _getInitial(contact.name);
                            final type = contact.contactType ?? 'Manual';

                            return Card(
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact.name ?? "-",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildTypeTag(type),
                                    ],
                                  ),
                                  subtitle: Text(
                                    contact.phone ?? "-",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) =>
                                            ContactCreateUpdateDialog(initial: contact),
                                      );
                                    },
                                    tooltip: "Edit Contact",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _selectedTypeFilter == key;
    return FilterChip(
      selected: isSelected,
      label: Text("$label ($count)"),
      onSelected: (_) {
        setState(() {
          _selectedTypeFilter = key;
        });
      },
    );
  }

  Widget _buildTypeTag(String type) {
    Color color;
    switch (type.toUpperCase()) {
      case 'GOOGLE':
        color = Colors.blue;
        break;
      case 'INTERNAL':
        color = Colors.purple;
        break;
      case 'IMPORTED':
        color = Colors.teal;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
