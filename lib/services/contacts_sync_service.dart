import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../models/contact.dart';

enum ContactMatchStatus { newContact, exactPhoneMatch, nameOnlyMatch }

class ClassifiedContact {
  final Contact contact;
  final ContactMatchStatus matchStatus;
  final Contact? matchedExistingContact;
  bool isSelected;

  ClassifiedContact({
    required this.contact,
    required this.matchStatus,
    this.matchedExistingContact,
    this.isSelected = true,
  });
}

class ContactsSyncService {
  /// Request contacts permission using flutter_contacts 2.1.0 permissions API
  static Future<bool> requestContactsPermission() async {
    try {
      final status = await fc.FlutterContacts.permissions.request(
        fc.PermissionType.read,
      );
      return status == fc.PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Check if contacts permission is already granted
  static Future<bool> hasContactsPermission() async {
    try {
      return await fc.FlutterContacts.permissions.has(fc.PermissionType.read);
    } catch (e) {
      return false;
    }
  }

  /// Normalize phone string: removes all non-digit characters except leading '+'
  static String normalizePhone(String? phone) {
    if (phone == null) return '';
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '').trim();
    if (cleaned.startsWith('+959')) {
      cleaned = '09${cleaned.substring(4)}';
    } else if (cleaned.startsWith('959')) {
      cleaned = '09${cleaned.substring(3)}';
    } else if (cleaned.startsWith('+95')) {
      cleaned = '0${cleaned.substring(3)}';
    }
    return cleaned;
  }

  /// Fetch contacts from device (Google / Device contacts)
  static Future<List<Contact>> fetchDeviceContacts() async {
    final hasPermission = await requestContactsPermission();
    if (!hasPermission) {
      throw Exception(
        "Contacts permission denied. Please enable contacts permission in settings.",
      );
    }

    final rawContacts = await fc.FlutterContacts.getAll(
      properties: {
        fc.ContactProperty.name,
        fc.ContactProperty.phone,
        fc.ContactProperty.address,
      },
    );

    return deduplicateRawContacts(rawContacts);
  }

  /// Deduplicate raw contacts from device to avoid multiple accounts/SIM duplicates
  static List<Contact> deduplicateRawContacts(List<fc.Contact> rawList) {
    final Map<String, Contact> phoneMap = {};
    final Map<String, Contact> nameMap = {};
    final List<Contact> uniqueContacts = [];

    for (final raw in rawList) {
      String name = '';
      if (raw.displayName != null && raw.displayName!.trim().isNotEmpty) {
        name = raw.displayName!.trim();
      } else if (raw.name != null) {
        final first = raw.name?.first ?? '';
        final last = raw.name?.last ?? '';
        name = '$first $last'.trim();
      }

      if (name.isEmpty && raw.phones.isEmpty) continue;

      // Extract all phone numbers from this device contact
      final phones = raw.phones
          .map((p) => p.number.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      final primaryPhone = phones.isNotEmpty ? phones.first : '';
      final normalizedPrimary = normalizePhone(primaryPhone);

      final address = raw.addresses.isNotEmpty
          ? (raw.addresses.first.formatted ?? raw.addresses.first.street)
          : null;

      final contact = Contact(
        name: name.isNotEmpty
            ? name
            : (primaryPhone.isNotEmpty ? primaryPhone : 'Unknown'),
        phone: primaryPhone.isNotEmpty ? primaryPhone : null,
        address: address,
        contactType: 'Google',
      );

      // Check if we've already added a contact with this normalized phone
      if (normalizedPrimary.isNotEmpty) {
        if (!phoneMap.containsKey(normalizedPrimary)) {
          phoneMap[normalizedPrimary] = contact;
          uniqueContacts.add(contact);
        }
      } else if (name.isNotEmpty) {
        final lowerName = name.toLowerCase();
        if (!nameMap.containsKey(lowerName)) {
          nameMap[lowerName] = contact;
          uniqueContacts.add(contact);
        }
      }
    }

    return uniqueContacts;
  }

  /// Classifies incoming contacts against existing DB contacts for duplicate handling
  static List<ClassifiedContact> classifyContacts({
    required List<Contact> incomingContacts,
    required List<Contact> existingContacts,
  }) {
    final Map<String, Contact> existingByPhone = {};
    final Map<String, Contact> existingByName = {};

    for (final existing in existingContacts) {
      final norm = normalizePhone(existing.phone);
      if (norm.isNotEmpty) {
        existingByPhone[norm] = existing;
      }
      if (existing.name != null && existing.name!.trim().isNotEmpty) {
        existingByName[existing.name!.trim().toLowerCase()] = existing;
      }
    }

    final List<ClassifiedContact> results = [];

    for (final incoming in incomingContacts) {
      final normIncoming = normalizePhone(incoming.phone);
      final incomingName = (incoming.name ?? '').trim().toLowerCase();

      if (normIncoming.isNotEmpty &&
          existingByPhone.containsKey(normIncoming)) {
        results.add(
          ClassifiedContact(
            contact: incoming,
            matchStatus: ContactMatchStatus.exactPhoneMatch,
            matchedExistingContact: existingByPhone[normIncoming],
            isSelected: false, // Default unselect exact duplicates
          ),
        );
      } else if (incomingName.isNotEmpty &&
          existingByName.containsKey(incomingName)) {
        results.add(
          ClassifiedContact(
            contact: incoming,
            matchStatus: ContactMatchStatus.nameOnlyMatch,
            matchedExistingContact: existingByName[incomingName],
            isSelected: true,
          ),
        );
      } else {
        results.add(
          ClassifiedContact(
            contact: incoming,
            matchStatus: ContactMatchStatus.newContact,
            isSelected: true,
          ),
        );
      }
    }

    return results;
  }

  /// Export contacts list to formatted JSON string
  static String exportToJson(List<Contact> contacts) {
    final list = contacts
        .map(
          (c) => {
            'name': c.name ?? '',
            'phone': c.phone ?? '',
            'nrc': c.nrc ?? '',
            'address': c.address ?? '',
            'contactType': c.contactType ?? 'Manual',
          },
        )
        .toList();

    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Export contacts list to CSV string
  static String exportToCsv(List<Contact> contacts) {
    final buffer = StringBuffer();
    buffer.writeln('Name,Phone,NRC,Address,ContactType');

    for (final c in contacts) {
      final name = _escapeCsv(c.name ?? '');
      final phone = _escapeCsv(c.phone ?? '');
      final nrc = _escapeCsv(c.nrc ?? '');
      final address = _escapeCsv(c.address ?? '');
      final contactType = _escapeCsv(c.contactType ?? 'Manual');
      buffer.writeln('$name,$phone,$nrc,$address,$contactType');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Parse JSON string into contacts
  static List<Contact> parseJsonContacts(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded.map((item) {
        if (item is Map<String, dynamic>) {
          return Contact.fromJson(item);
        } else if (item is Map) {
          return Contact.fromJson(Map<String, dynamic>.from(item));
        }
        throw Exception("Invalid item in JSON list");
      }).toList();
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['contacts'] is List) {
        return (decoded['contacts'] as List)
            .map((item) => Contact.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [Contact.fromJson(decoded)];
    }
    throw Exception("Unsupported JSON format for contacts");
  }

  /// Parse CSV string into contacts
  static List<Contact> parseCsvContacts(String csvStr) {
    final lines = csvStr
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    final List<Contact> contacts = [];
    final hasHeader =
        lines.first.toLowerCase().contains('name') ||
        lines.first.toLowerCase().contains('phone');
    final startIndex = hasHeader ? 1 : 0;

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      final columns = _parseCsvLine(line);
      if (columns.isEmpty) continue;

      final name = columns.isNotEmpty ? columns[0].trim() : '';
      final phone = columns.length > 1 ? columns[1].trim() : '';
      final nrc = columns.length > 2 ? columns[2].trim() : '';
      final address = columns.length > 3 ? columns[3].trim() : '';
      final contactType = columns.length > 4 ? columns[4].trim() : 'Imported';

      if (name.isNotEmpty || phone.isNotEmpty) {
        contacts.add(
          Contact(
            name: name.isNotEmpty ? name : 'Unnamed',
            phone: phone.isNotEmpty ? phone : null,
            nrc: nrc.isNotEmpty ? nrc : null,
            address: address.isNotEmpty ? address : null,
            contactType: contactType.isNotEmpty ? contactType : 'Imported',
          ),
        );
      }
    }

    return contacts;
  }

  static List<String> _parseCsvLine(String line) {
    final List<String> fields = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        fields.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    fields.add(current.toString());
    return fields;
  }
}
