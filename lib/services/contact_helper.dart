import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactHelper {
  static Future<Contact?> pickContactFromList(BuildContext context) async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) return null;

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    return await showDialog<Contact>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn liên hệ'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (_, index) {
              final c = contacts[index];
              return ListTile(
                title: Text(c.displayName.isNotEmpty ? c.displayName : 'Không tên'),
                subtitle: Text(c.phones.isNotEmpty ? c.phones.first.number : ''),
                onTap: () => Navigator.pop(context, c),
              );
            },
          ),
        ),
      ),
    );
  }
}
