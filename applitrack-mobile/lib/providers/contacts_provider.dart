import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../services/hive_service.dart';

part 'contacts_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class ContactsNotifier extends _$ContactsNotifier {
  @override
  List<Contact> build() => _loadAll();

  List<Contact> _loadAll() {
    return HiveService.contactsBox.values
        .map((raw) => Contact.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Contact> add({
    required String applicationId,
    required String name,
    String? title,
    String? email,
    String? phone,
    String? linkedinUrl,
    String? notes,
  }) async {
    final contact = Contact(
      id: _uuid.v4(),
      applicationId: applicationId,
      name: name,
      title: title,
      email: email,
      phone: phone,
      linkedinUrl: linkedinUrl,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await HiveService.contactsBox.put(contact.id, contact.toJson());
    state = _loadAll();
    return contact;
  }

  Future<void> delete(String id) async {
    await HiveService.contactsBox.delete(id);
    state = _loadAll();
  }

  List<Contact> forApplication(String applicationId) =>
      state.where((c) => c.applicationId == applicationId).toList();
}
