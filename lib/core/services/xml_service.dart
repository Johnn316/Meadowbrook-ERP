import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

import '../../features/crm/contacts/domain/contact_model.dart';
import '../../features/crm/invoices/domain/invoice_model.dart';
import '../../features/crm/leads/domain/lead_model.dart';
import '../database/drift/app_database.dart';

enum ExportTable { contacts, leads, invoices, all }

class XmlService {
  // ─── EXPORT ──────────────────────────────────────────────────────────────────

  /// Builds an XML document for the requested table(s), saves it as a temp
  /// file, then opens the system share sheet so the user can save / send it.
  static Future<void> exportAndShare(ExportTable table) async {
    final contacts = (table == ExportTable.contacts || table == ExportTable.all)
        ? await AppDatabase.getContacts()
        : <ContactModel>[];

    final leads = (table == ExportTable.leads || table == ExportTable.all)
        ? await AppDatabase.getLeads()
        : <LeadModel>[];

    final invoices =
        (table == ExportTable.invoices || table == ExportTable.all)
            ? await AppDatabase.getInvoices()
            : <InvoiceModel>[];

    final doc = _buildXml(
      contacts: contacts,
      leads: leads,
      invoices: invoices,
      exported: DateTime.now().toIso8601String(),
    );

    final fileName = _fileName(table);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(doc.toXmlString(pretty: true));

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/xml')],
      subject: 'Meadowbrook ERP — $fileName',
    );
  }

  // ─── IMPORT ──────────────────────────────────────────────────────────────────

  /// Opens the file picker, parses the chosen XML, and upserts records into the
  /// database.  Returns a summary string or throws on failure.
  static Future<String> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (result == null || result.files.single.path == null) {
      return 'Import cancelled.';
    }

    final file = File(result.files.single.path!);
    final contents = await file.readAsString();
    final doc = XmlDocument.parse(contents);

    int contacts = 0, leads = 0, invoices = 0;

    // Contacts
    for (final node in doc.findAllElements('contact')) {
      final model = _contactFromXml(node);
      await AppDatabase.upsertContact(model);
      contacts++;
    }

    // Leads
    for (final node in doc.findAllElements('lead')) {
      final model = _leadFromXml(node);
      await AppDatabase.upsertLead(model);
      leads++;
    }

    // Invoices
    for (final node in doc.findAllElements('invoice')) {
      final model = _invoiceFromXml(node);
      await AppDatabase.upsertInvoice(model);
      invoices++;
    }

    return 'Imported: $contacts contacts, $leads leads, $invoices invoices.';
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  static String _fileName(ExportTable table) {
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    switch (table) {
      case ExportTable.contacts:
        return 'contacts_$ts.xml';
      case ExportTable.leads:
        return 'leads_$ts.xml';
      case ExportTable.invoices:
        return 'invoices_$ts.xml';
      case ExportTable.all:
        return 'meadowbrook_erp_$ts.xml';
    }
  }

  static XmlDocument _buildXml({
    required List<ContactModel> contacts,
    required List<LeadModel> leads,
    required List<InvoiceModel> invoices,
    required String exported,
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('meadowbrook_erp', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute('exported', exported);

      if (contacts.isNotEmpty) {
        builder.element('contacts', nest: () {
          for (final c in contacts) {
            builder.element('contact', nest: () {
              builder.element('id', nest: c.id);
              builder.element('name', nest: c.name);
              builder.element('phone', nest: c.phone);
              builder.element('email', nest: c.email);
              builder.element('type', nest: c.type);
              builder.element('county', nest: c.county);
              builder.element('createdAt', nest: c.createdAt);
            });
          }
        });
      }

      if (leads.isNotEmpty) {
        builder.element('leads', nest: () {
          for (final l in leads) {
            builder.element('lead', nest: () {
              builder.element('id', nest: l.id);
              builder.element('title', nest: l.title);
              builder.element('contactName', nest: l.contactName);
              builder.element('phone', nest: l.phone);
              builder.element('status', nest: l.status);
              builder.element('value', nest: l.value.toString());
              builder.element('notes', nest: l.notes);
              builder.element('createdAt', nest: l.createdAt);
            });
          }
        });
      }

      if (invoices.isNotEmpty) {
        builder.element('invoices', nest: () {
          for (final inv in invoices) {
            builder.element('invoice', nest: () {
              builder.element('id', nest: inv.id);
              builder.element('invoiceNumber', nest: inv.invoiceNumber);
              builder.element('clientName', nest: inv.clientName);
              builder.element('clientPhone', nest: inv.clientPhone);
              builder.element('amount', nest: inv.amount.toString());
              builder.element('amountPaid', nest: inv.amountPaid.toString());
              builder.element('status', nest: inv.status);
              builder.element('dueDate', nest: inv.dueDate);
              builder.element('notes', nest: inv.notes);
              builder.element('createdAt', nest: inv.createdAt);
            });
          }
        });
      }
    });

    return builder.buildDocument();
  }

  static String _text(XmlElement node, String tag) =>
      node.findElements(tag).firstOrNull?.innerText ?? '';

  static double _double(XmlElement node, String tag) =>
      double.tryParse(_text(node, tag)) ?? 0.0;

  static ContactModel _contactFromXml(XmlElement node) => ContactModel(
        id: _text(node, 'id'),
        name: _text(node, 'name'),
        phone: _text(node, 'phone'),
        email: _text(node, 'email'),
        type: _text(node, 'type'),
        county: _text(node, 'county'),
        createdAt: _text(node, 'createdAt'),
      );

  static LeadModel _leadFromXml(XmlElement node) => LeadModel(
        id: _text(node, 'id'),
        title: _text(node, 'title'),
        contactName: _text(node, 'contactName'),
        phone: _text(node, 'phone'),
        status: _text(node, 'status'),
        value: _double(node, 'value'),
        notes: _text(node, 'notes'),
        createdAt: _text(node, 'createdAt'),
      );

  static InvoiceModel _invoiceFromXml(XmlElement node) => InvoiceModel(
        id: _text(node, 'id'),
        invoiceNumber: _text(node, 'invoiceNumber'),
        clientName: _text(node, 'clientName'),
        clientPhone: _text(node, 'clientPhone'),
        amount: _double(node, 'amount'),
        amountPaid: _double(node, 'amountPaid'),
        status: _text(node, 'status'),
        dueDate: _text(node, 'dueDate'),
        notes: _text(node, 'notes'),
        createdAt: _text(node, 'createdAt'),
      );
}
