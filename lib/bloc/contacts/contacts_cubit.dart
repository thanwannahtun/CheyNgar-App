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

  Future<void> fetchContacts() async {
    try {
      // if (state.contacts?.isNotEmpty ?? false) {
      //   // emit(state.copyWith(status: BlocStatus.success));
      //   return;
      // }

      emit(state.copyWith(status: BlocStatus.loading));
      final contacts = await _contactsRepo.fetchContacts();

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
}
