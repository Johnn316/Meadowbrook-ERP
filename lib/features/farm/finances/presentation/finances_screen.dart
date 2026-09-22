import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../domain/finance_model.dart';

class FinancesScreen extends StatefulWidget {
  final String farmId;
  final String farmName;
  const FinancesScreen({super.key, required this.farmId, required this.farmName});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  List<FinanceModel> _items = [];
  bool _loading = true;

  static const _categories = ['Crop Sales', 'Livestock Sales', 'Feed', 'Labour', 'Equipment', 'Seeds', 'Fertilizer', 'Other'];

  double get _totalIncome => _items.where((f) => f.type == 'Income').fold(0.0, (s, f) => s + f.amount);
  double get _totalExpense => _items.where((f) => f.type == 'Expense').fold(0.0, (s, f) => s + f.amount);
  double get _netProfit => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await AppDatabase.getFarmFinances(widget.farmId);
    setState(() => _loading = false);
  }

  void _showSheet({FinanceModel? existing}) {
    String type = existing?.type ?? 'Income';
    String category = existing?.category.isNotEmpty == true ? existing!.category : _categories.first;
    final amountCtrl = TextEditingController(text: existing?.amount == 0 ? '' : existing?.amount.toStringAsFixed(0) ?? '');
    final dateCtrl = TextEditingController(text: existing?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(existing == null ? 'Add Transaction' : 'Edit Transaction',
                      style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        final ok = await _confirmDelete(ctx);
                        if (ok && ctx.mounted) {
                          await AppDatabase.deleteFarmFinance(existing.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _load();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Income / Expense toggle
              Row(
                children: ['Income', 'Expense'].map((t) {
                  final selected = type == t;
                  final color = t == 'Income' ? AppColors.success : AppColors.error;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: t == 'Income' ? 6 : 0, left: t == 'Expense' ? 6 : 0),
                      child: OutlinedButton(
                        onPressed: () => setModal(() => type = t),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected ? color.withValues(alpha: 0.1) : null,
                          foregroundColor: color,
                          side: BorderSide(color: selected ? color : AppColors.textLight),
                        ),
                        child: Text(t, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.label_outline), labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModal(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Amount (Ksh)', prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(hintText: 'Date (yyyy-MM-dd)', prefixIcon: Icon(Icons.calendar_today_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Notes (optional)', prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                  if (amount == 0) return;
                  final now = DateTime.now().toIso8601String();
                  if (existing == null) {
                    await AppDatabase.insertFarmFinance(FinanceModel(
                      id: const Uuid().v4(),
                      farmId: widget.farmId,
                      type: type,
                      category: category,
                      amount: amount,
                      date: dateCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      createdAt: now,
                    ));
                  } else {
                    await AppDatabase.updateFarmFinance(existing.copyWith(
                      type: type,
                      category: category,
                      amount: amount,
                      date: dateCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                    ));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: Text(existing == null ? 'Save Transaction' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Delete this transaction? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finances — ${widget.farmName}',
            style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary header
                Container(
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
                      Expanded(child: _StatCol(label: 'Income', value: CurrencyUtils.format(_totalIncome), color: Colors.greenAccent)),
                      Container(width: 1, height: 36, color: Colors.white30),
                      Expanded(child: _StatCol(label: 'Expenses', value: CurrencyUtils.format(_totalExpense), color: Colors.redAccent)),
                      Container(width: 1, height: 36, color: Colors.white30),
                      Expanded(
                        child: _StatCol(
                          label: 'Net Profit',
                          value: CurrencyUtils.format(_netProfit),
                          color: _netProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textLight),
                              const SizedBox(height: 12),
                              Text('No transactions yet', style: GoogleFonts.lato(color: AppColors.textSecondary, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Tap + to record income or expense', style: GoogleFonts.lato(color: AppColors.textLight, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final item = _items[i];
                            final isIncome = item.type == 'Income';
                            final color = isIncome ? AppColors.success : AppColors.error;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.12),
                                  child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 18),
                                ),
                                title: Text(item.category, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                                subtitle: Text(item.date, style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary)),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${CurrencyUtils.format(item.amount)}',
                                  style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                                ),
                                onTap: () => _showSheet(existing: item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSheet(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCol({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.merriweather(color: color, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.lato(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
