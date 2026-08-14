import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chey_ngar/core/api_utils/api_error_handler.dart';
import 'package:chey_ngar/core/bloc_utils/bloc_status.dart';
import 'package:chey_ngar/models/contact.dart';

import '../../repositories/contacts_repo.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepo _contactsRepo;
  ContactsCubit(this._contactsRepo) : super(const ContactsState.init());

  Future<void> fetchContacts({
    String? query,
    String? contactType,
    bool all = true,
    bool isRefresh = false,
  }) async {
    try {
      if (!isRefresh) {
        emit(state.copyWith(status: BlocStatus.loading));
      }
      final contacts = await _contactsRepo.fetchContacts(
        query: query,
        contactType: contactType,
        all: all,
      );

      emit(
        state.copyWith(
          status: BlocStatus.success,
          contacts: contacts,
          filtedContacts: contacts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  void filterByReferenceNo(String name) {
    final filtered = (state.contacts ?? [])
        .where((r) => (r.name ?? "").toUpperCase().contains(name.toUpperCase()))
        .toList();
    emit(state.copyWith(filtedContacts: filtered));
  }

  Future<void> createContact(Contact contact) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      final created = await _contactsRepo.createContact(contact);
      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          contacts: [...state.contacts ?? [], created],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          crudStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      final result = await _contactsRepo.updateContact(contact);
      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          contacts: state.contacts
              ?.map((e) => e.id == contact.id ? result : e)
              .toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          crudStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      await _contactsRepo.deleteContact(id);
      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          contacts: state.contacts?.where((e) => e.id != id).toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          crudStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> batchImportContacts(
    List<Contact> contacts, {
    String mergeStrategy = 'skip',
  }) async {
    try {
      emit(state.copyWith(crudStatus: BlocStatus.loading));
      final result = await _contactsRepo.batchImportContacts(
        contacts,
        mergeStrategy: mergeStrategy,
      );

      // Refresh contacts list from server after import
      final updatedContacts = await _contactsRepo.fetchContacts();

      final imported = result['importedCount'] ?? 0;
      final updated = result['updatedCount'] ?? 0;
      final skipped = result['skippedCount'] ?? 0;

      emit(
        state.copyWith(
          crudStatus: BlocStatus.success,
          contacts: updatedContacts,
          filtedContacts: updatedContacts,
          message: 'Imported: $imported, Updated: $updated, Skipped: $skipped',
        ),
      );
      return result;
    } catch (e) {
      emit(
        state.copyWith(
          crudStatus: BlocStatus.failure,
          message: handleErrorMessage(e),
        ),
      );
      return null;
    }
  }
}
