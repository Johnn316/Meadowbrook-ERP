import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../data/leads_provider.dart';
import '../domain/lead_model.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _selectedStatus = 'All';
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadsProvider>().loadLeads();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LeadModel> _filtered(List<LeadModel> leads) {
    return leads.where((l) {
      final matchStatus = _selectedStatus == 'All' || l.status == _selectedStatus;
      final q = _query.toLowerCase();
      final matchQuery = q.isEmpty ||
          l.title.toLowerCase().contains(q) ||
          l.contactName.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.info;
      case 'Contacted':
        return AppColors.secondary;
      case 'Qualified':
        return AppColors.primaryLight;
      case 'Proposal':
        return Colors.purple;
      case 'Won':
        return AppColors.success;
      case 'Lost':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadsProvider>();
    final filtered = _filtered(provider.leads.toList());
    final totalValue = filtered.fold(0.0, (s, l) => s + l.value);
    final wonCount =
        provider.leads.where((l) => l.status == 'Won').length;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pipeline Value',
                        style: GoogleFonts.lato(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(totalValue),
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${filtered.length} leads',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$wonCount won',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search leads…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ['All', ...AppConstants.leadStatuses].map((status) {
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
                            const Icon(Icons.trending_up,
                                size: 64, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'No leads found',
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
                          final lead = filtered[index];
                          return _LeadCard(
                            lead: lead,
                            statusColor: _statusColor(lead.status),
                            onTap: () => _showEditLeadSheet(context, lead),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeadSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Lead',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showEditLeadSheet(BuildContext context, LeadModel lead) {
    final titleController = TextEditingController(text: lead.title);
    final contactController = TextEditingController(text: lead.contactName);
    final phoneController = TextEditingController(text: lead.phone);
    final valueController =
        TextEditingController(text: lead.value == 0 ? '' : lead.value.toStringAsFixed(0));
    final notesController = TextEditingController(text: lead.notes);
    String selectedStatus = lead.status;
    final provider = context.read<LeadsProvider>();

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
                    'Edit Lead',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Delete lead',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Delete Lead'),
                          content: Text(
                              'Delete "${lead.title}"? This cannot be undone.'),
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
                        provider.deleteLead(lead.id);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Lead title',
                  prefixIcon: Icon(Icons.trending_up_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  hintText: 'Contact name',
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
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Estimated value (Ksh)',
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
                items: AppConstants.leadStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final updated = lead.copyWith(
                    title: titleController.text.trim(),
                    contactName: contactController.text.trim(),
                    phone: phoneController.text.trim(),
                    value: double.tryParse(valueController.text) ?? lead.value,
                    notes: notesController.text.trim(),
                    status: selectedStatus,
                  );
                  provider.updateLead(updated);
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

  void _showAddLeadSheet(BuildContext context) {
    final titleController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final valueController = TextEditingController();
    String selectedStatus = 'New';
    final provider = context.read<LeadsProvider>();

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
                'New Lead',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Lead title',
                  prefixIcon: Icon(Icons.trending_up_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  hintText: 'Contact name',
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
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Estimated value (Ksh)',
                  prefixIcon: Icon(Icons.attach_money),
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
                items: AppConstants.leadStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    provider.addLead(
                      title: titleController.text,
                      contactName: contactController.text,
                      phone: phoneController.text,
                      status: selectedStatus,
                      value: double.tryParse(valueController.text) ?? 0.0,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Lead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ─── WIDGETS ──────────────────────────────────────────────────────────────────

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final Color statusColor;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    lead.title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
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
                    lead.status,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  lead.contactName,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.phone_outlined,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  lead.phone,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lead.notes,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CurrencyUtils.format(lead.value),
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }
}
