import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/crm/invoices/domain/invoice_model.dart';

class PdfService {
  static String _formatKsh(double amount) {
    return 'KES ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  static Future<void> shareInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    final outstanding = invoice.amount - invoice.amountPaid;
    final issueDate = invoice.createdAt.isNotEmpty
        ? invoice.createdAt.substring(0, 10)
        : '—';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MEADOWBROOK ERP',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2D6A4F'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Smart Farming & Business Management',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromHex('#6B7280'),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2D6A4F'),
                        ),
                      ),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromHex('#374151'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Divider(color: PdfColor.fromHex('#2D6A4F'), thickness: 2),
              pw.SizedBox(height: 20),

              // ── Bill To / Dates ──────────────────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#6B7280'),
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          invoice.clientName.isNotEmpty ? invoice.clientName : '—',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        if (invoice.clientPhone.isNotEmpty)
                          pw.Text(
                            invoice.clientPhone,
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('#6B7280')),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _dateRow('Issue Date', issueDate),
                        if (invoice.dueDate.isNotEmpty)
                          _dateRow('Due Date', invoice.dueDate),
                        pw.SizedBox(height: 6),
                        _statusBadge(invoice.status),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 32),

              // ── Table header ─────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#2D6A4F'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Amount',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Table row ────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromHex('#E5E7EB')),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            invoice.notes.isNotEmpty ? invoice.notes : 'Services rendered',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatKsh(invoice.amount),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // ── Totals ───────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 260,
                    child: pw.Column(
                      children: [
                        _totalRow('Subtotal', _formatKsh(invoice.amount)),
                        _totalRow('Amount Paid', _formatKsh(invoice.amountPaid),
                            valueColor: PdfColor.fromHex('#059669')),
                        pw.Divider(color: PdfColor.fromHex('#D1D5DB')),
                        _totalRow(
                          'Outstanding',
                          _formatKsh(outstanding),
                          bold: true,
                          valueColor: outstanding > 0
                              ? PdfColor.fromHex('#DC2626')
                              : PdfColor.fromHex('#059669'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // ── Footer ───────────────────────────────────────────────
              pw.Divider(color: PdfColor.fromHex('#E5E7EB')),
              pw.SizedBox(height: 8),
              pw.Text(
                'Thank you for your business — Meadowbrook ERP',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#9CA3AF'),
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${invoice.invoiceNumber}.pdf',
    );
  }

  static pw.Widget _dateRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#6B7280')),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _statusBadge(String status) {
    final color = status == 'Paid'
        ? PdfColor.fromHex('#059669')
        : status == 'Overdue'
            ? PdfColor.fromHex('#DC2626')
            : PdfColor.fromHex('#D97706');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        status.toUpperCase(),
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromHex('#374151'),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? PdfColor.fromHex('#374151'),
            ),
          ),
        ],
      ),
    );
  }
}
