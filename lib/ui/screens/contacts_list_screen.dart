import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/platform.dart';
import '../../bloc/contacts/contacts_cubit.dart';
import '../widgets/dialogs/contact_create_update_dialog.dart';
import '../widgets/error_message.dart';
import '../widgets/loading.dart';
import '../widgets/no_data.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().fetchContacts();
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
        tooltip: "New Transaction",
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Contacts"),

        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined),
            onSelected: (value) async {
              if (value == 'logout') {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
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
              PopupMenuItem(
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
            return Loading();
          }

          if (state.status == BlocStatus.failure) {
            return ErrorMessage(
              message: state.message ?? "❌Error!",
              onRetry: () {
                context.read<ContactsCubit>().fetchContacts();
              },
            );
          }

          if (state.contacts == null || state.contacts!.isEmpty) {
            return NoData(message: "No Contacts");
          }

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

          return GridView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            itemCount: state.contacts!.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final contact = state.contacts![index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: ListTile(
                    title: Text(
                      contact.name ?? "-",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    subtitle: Text(
                      contact.phone ?? "-",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    leading: CircleAvatar(
                      child: (contact.name != null && contact.name!.isNotEmpty)
                          ? Text(
                              (contact.name != null && contact.name!.isNotEmpty)
                                  ? contact.name!.substring(0, 1).toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.launch_rounded),
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) =>
                              ContactCreateUpdateDialog(initial: contact),
                        );
                      },
                      tooltip: "Detail",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
