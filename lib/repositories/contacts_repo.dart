import '../core/api_utils/api_service.dart';
import '../models/contact.dart';

class ContactsRepo extends ApiService {
  ContactsRepo();

  Future<List<Contact>> fetchContacts() async {
    try {
      final response = await getRequest('/contacts');
      if (response.statusCode == 200) {
        return (response.data["data"] as List)
            .map((e) => Contact.fromJson(e))
            .toList();
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Contact> createContact(Contact value) async {
    try {
      final response = await postRequest('/contacts', value.toJson());
      if (response.statusCode == 201) {
        return Contact.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Contact> updateContact(Contact contact) async {
    try {
      final response = await putRequest(
        '/contacts/${contact.id}',
        contact.toJson(),
      );
      if (response.statusCode == 200) {
        return Contact.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteContact(int id) async {
    try {
      final response = await deleteRequest('/contacts/$id');
      if (response.statusCode == 200) {
        return true;
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }

  Future<Contact> fetchContactDetail(int id) async {
    try {
      final response = await getRequest('/contacts/$id/summary');
      if (response.statusCode == 200) {
        return Contact.fromJson(response.data["data"]);
      }
      throw Exception("Invalid Response!");
    } catch (e) {
      rethrow;
    }
  }
}
