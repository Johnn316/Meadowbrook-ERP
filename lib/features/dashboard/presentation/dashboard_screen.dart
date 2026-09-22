import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../crm/contacts/data/contacts_provider.dart';
import '../../crm/invoices/data/invoices_provider.dart';
import '../../crm/leads/data/leads_provider.dart';
import '../../farm/farms/data/farms_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
      context.read<LeadsProvider>().loadLeads();
      context.read<InvoicesProvider>().loadInvoices();
      context.read<FarmsProvider>().loadFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsProvider>();
    final leads = context.watch<LeadsProvider>();
    final invoices = context.watch<InvoicesProvider>();
    final farms = context.watch<FarmsProvider>();

    final openLeads = leads.leads.where((l) => l.status != 'Won' && l.status != 'Lost').length;
    final wonLeads = leads.leads.where((l) => l.status == 'Won').length;
    final recentLeads = leads.leads.take(3).toList();
    final recentInvoices = invoices.invoices.take(3).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<ContactsProvider>().loadContacts(),
            context.read<LeadsProvider>().loadLeads(),
            context.read<InvoicesProvider>().loadInvoices(),
            context.read<FarmsProvider>().loadFarms(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good day,',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meadowbrook ERP',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Finance summary inside header
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderStat(
                            label: 'Total Invoiced',
                            value: CurrencyUtils.format(invoices.totalAmount),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.white30),
                        Expanded(
                          child: _HeaderStat(
                            label: 'Outstanding',
                            value: CurrencyUtils.format(invoices.totalOutstanding),
                            valueColor: Colors.orangeAccent,
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.white30),
                        Expanded(
                          child: _HeaderStat(
                            label: 'Collected',
                            value: CurrencyUtils.format(invoices.totalPaid),
                            valueColor: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Summary cards ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Overview',
                  style: GoogleFonts.merriweather(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _SummaryCard(
                      label: 'Contacts',
                      value: '${contacts.contacts.length}',
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                    _SummaryCard(
                      label: 'Open Leads',
                      value: '$openLeads',
                      subLabel: '$wonLeads won',
                      icon: Icons.trending_up,
                      color: AppColors.secondary,
                    ),
                    _SummaryCard(
                      label: 'Invoices',
                      value: '${invoices.invoices.length}',
                      icon: Icons.receipt_long,
                      color: AppColors.info,
                    ),
                    _SummaryCard(
                      label: 'Farms',
                      value: '${farms.farms.length}',
                      icon: Icons.agriculture,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),

              // ── Recent leads ─────────────────────────────────────────
              if (recentLeads.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Recent Leads',
                    style: GoogleFonts.merriweather(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...recentLeads.map((lead) {
                  final color = _statusColor(lead.status);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(Icons.trending_up,
                              color: color, size: 18),
                        ),
                        title: Text(
                          lead.title,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          lead.contactName,
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lead.status,
                                style: GoogleFonts.lato(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyUtils.format(lead.value),
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],

              // ── Recent invoices ──────────────────────────────────────
              if (recentInvoices.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Recent Invoices',
                    style: GoogleFonts.merriweather(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...recentInvoices.map((inv) {
                  final color = _invoiceStatusColor(inv.status);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(Icons.receipt,
                              color: color, size: 18),
                        ),
                        title: Text(
                          inv.clientName,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          inv.invoiceNumber,
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                inv.status,
                                style: GoogleFonts.lato(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyUtils.format(inv.amount),
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New': return AppColors.info;
      case 'Contacted': return AppColors.secondary;
      case 'Qualified': return AppColors.primaryLight;
      case 'Proposal': return Colors.purple;
      case 'Won': return AppColors.success;
      case 'Lost': return AppColors.error;
      default: return AppColors.textLight;
    }
  }

  Color _invoiceStatusColor(String status) {
    switch (status) {
      case 'Paid': return AppColors.success;
      case 'Unpaid': return AppColors.error;
      case 'Overdue': return Colors.deepOrange;
      case 'Partial': return Colors.orange;
      case 'Draft': return AppColors.textLight;
      default: return AppColors.textLight;
    }
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HeaderStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.merriweather(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lato(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.merriweather(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (subLabel != null)
                  Text(
                    subLabel!,
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
