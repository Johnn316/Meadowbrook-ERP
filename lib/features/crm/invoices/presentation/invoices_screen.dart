import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice_model.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _selectedStatus = 'All';

  static const _statuses = ['All', 'Paid', 'Unpaid', 'Partial', 'Overdue'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoicesProvider>().loadInvoices();
    });
  }

  List<InvoiceModel> _filtered(List<InvoiceModel> invoices) {
    return invoices
        .where((inv) =>
            _selectedStatus == 'All' || inv.status == _selectedStatus)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return AppColors.success;
      case 'Unpaid':
        return AppColors.info;
      case 'Partial':
        return AppColors.secondary;
      case 'Overdue':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoicesProvider>();
    final filtered = _filtered(provider.invoices.toList());

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Invoiced',
                    value: CurrencyUtils.format(provider.totalAmount),
                    color: AppColors.primary,
                    icon: Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Collected',
                    value: CurrencyUtils.format(provider.totalPaid),
                    color: AppColors.success,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Outstanding',
                    value: CurrencyUtils.format(provider.totalOutstanding),
                    color: AppColors.error,
                    icon: Icons.pending_outlined,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedStatus = status),
                      selectedColor:
                          _statusColor(status).withValues(alpha: 0.15),
                      checkmarkColor: _statusColor(status),
                      labelStyle: GoogleFonts.lato(
                        color: isSelected
                            ? _statusColor(status)
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_outlined,
                                size: 64, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'No invoices found',
                              style: GoogleFonts.lato(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final invoice = filtered[index];
                          return _InvoiceCard(
                            invoice: invoice,
                            statusColor: _statusColor(invoice.status),
                            onTap: () => _showEditInvoiceSheet(context, invoice),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInvoiceSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Invoice',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showEditInvoiceSheet(BuildContext context, InvoiceModel invoice) {
    final clientController = TextEditingController(text: invoice.clientName);
    final phoneController = TextEditingController(text: invoice.clientPhone);
    final amountController = TextEditingController(
        text: invoice.amount == 0 ? '' : invoice.amount.toStringAsFixed(0));
    final paidController = TextEditingController(
        text: invoice.amountPaid == 0 ? '' : invoice.amountPaid.toStringAsFixed(0));
    final notesController = TextEditingController(text: invoice.notes);
    String selectedStatus = invoice.status;
    final provider = context.read<InvoicesProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit ${invoice.invoiceNumber}',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Delete invoice',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Delete Invoice'),
                          content: Text(
                              'Delete "${invoice.invoiceNumber}"? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dCtx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dCtx, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && ctx.mounted) {
                        provider.deleteInvoice(invoice.id);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientController,
                decoration: const InputDecoration(
                  hintText: 'Client name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Total amount (Ksh)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount paid (Ksh)',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const ['Unpaid', 'Partial', 'Paid', 'Overdue']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newAmount =
                      double.tryParse(amountController.text) ?? invoice.amount;
                  final newPaid =
                      double.tryParse(paidController.text) ?? invoice.amountPaid;
                  final updated = invoice.copyWith(
                    clientName: clientController.text.trim(),
                    clientPhone: phoneController.text.trim(),
                    amount: newAmount,
                    amountPaid: newPaid,
                    status: selectedStatus,
                    notes: notesController.text.trim(),
                  );
                  provider.updateInvoice(updated);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInvoiceSheet(BuildContext context) {
    final clientController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedStatus = 'Unpaid';
    final provider = context.read<InvoicesProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Invoice',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientController,
                decoration: const InputDecoration(
                  hintText: 'Client name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount (Ksh)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const ['Unpaid', 'Partial', 'Paid']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (clientController.text.isNotEmpty) {
                    provider.addInvoice(
                      clientName: clientController.text,
                      clientPhone: phoneController.text,
                      amount:
                          double.tryParse(amountController.text) ?? 0.0,
                      status: selectedStatus,
                      notes: notesController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WIDGETS ──────────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final Color statusColor;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.statusColor,
    required this.onTap,
  });

  Future<void> _exportPdf(BuildContext context) async {
    try {
      await PdfService.shareInvoicePdf(invoice);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        invoice.amount > 0 ? invoice.amountPaid / invoice.amount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        invoice.clientName,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice.status,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined,
                      color: AppColors.error, size: 20),
                  tooltip: 'Export PDF',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _exportPdf(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.cardBg,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: ${CurrencyUtils.format(invoice.amountPaid)}',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: ${CurrencyUtils.format(invoice.amount)}',
                  style: GoogleFonts.merriweather(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (invoice.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                invoice.notes,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.merriweather(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
