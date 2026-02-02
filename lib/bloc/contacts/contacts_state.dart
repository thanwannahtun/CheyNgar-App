part of 'contacts_cubit.dart';

class ContactsState extends Equatable {
  final BlocStatus? status;
  final BlocStatus? crudStatus;
  final List<Contact>? contacts;
  final List<Contact>? filtedContacts;
  final String? message;

  const ContactsState({
    this.status,
    this.crudStatus,
    this.contacts,
    this.filtedContacts,
    this.message,
  });

  const ContactsState.init()
    : status = BlocStatus.initial,
      crudStatus = null,
      contacts = null,
      filtedContacts = null,
      message = null;

  ContactsState copyWith({
    BlocStatus? status,
    BlocStatus? crudStatus,
    List<Contact>? contacts,
    List<Contact>? filtedContacts,
    String? message,
  }) {
    return ContactsState(
      status: status ?? this.status,
      crudStatus: crudStatus ?? this.crudStatus,
      contacts: contacts ?? this.contacts,
      filtedContacts: filtedContacts ?? this.filtedContacts,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    crudStatus,
    contacts,
    message,
    filtedContacts,
  ];
}
