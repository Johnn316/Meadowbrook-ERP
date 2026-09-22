import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/drift/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/livestock_model.dart';

class LivestockScreen extends StatefulWidget {
  final String farmId;
  final String farmName;
  const LivestockScreen({super.key, required this.farmId, required this.farmName});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  List<LivestockModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await AppDatabase.getLivestock(widget.farmId);
    setState(() => _loading = false);
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Cattle': return Icons.set_meal;
      case 'Chickens': return Icons.egg_outlined;
      case 'Goats': case 'Sheep': return Icons.pets;
      default: return Icons.cruelty_free;
    }
  }

  void _showSheet({LivestockModel? existing}) {
    String type = existing?.type ?? AppConstants.kenyanLivestock.first;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final countCtrl = TextEditingController(
        text: existing?.count == 0 ? '' : existing?.count.toString() ?? '');
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
                  Text(existing == null ? 'Add Livestock' : 'Edit Livestock',
                      style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        final ok = await _confirmDelete(ctx, existing.type);
                        if (ok && ctx.mounted) {
                          await AppDatabase.deleteLivestock(existing.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _load();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.pets_outlined), labelText: 'Type'),
                items: AppConstants.kenyanLivestock
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModal(() => type = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Group / herd name (optional)', prefixIcon: Icon(Icons.label_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Number of animals', prefixIcon: Icon(Icons.numbers)),
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
                  final now = DateTime.now().toIso8601String();
                  if (existing == null) {
                    await AppDatabase.insertLivestock(LivestockModel(
                      id: const Uuid().v4(),
                      farmId: widget.farmId,
                      type: type,
                      name: nameCtrl.text.trim(),
                      count: int.tryParse(countCtrl.text) ?? 0,
                      notes: notesCtrl.text.trim(),
                      createdAt: now,
                    ));
                  } else {
                    await AppDatabase.updateLivestock(existing.copyWith(
                      type: type,
                      name: nameCtrl.text.trim(),
                      count: int.tryParse(countCtrl.text) ?? existing.count,
                      notes: notesCtrl.text.trim(),
                    ));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: Text(existing == null ? 'Save Livestock' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx, String name) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Delete Livestock'),
        content: Text('Delete "$name"? This cannot be undone.'),
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
        title: Text('Livestock — ${widget.farmName}',
            style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('No livestock recorded', style: GoogleFonts.lato(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Tap + to add livestock', style: GoogleFonts.lato(color: AppColors.textLight, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                          child: Icon(_typeIcon(item.type), color: AppColors.secondary, size: 20),
                        ),
                        title: Text(item.name.isNotEmpty ? item.name : item.type,
                            style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          item.name.isNotEmpty ? '${item.type} · ${item.count} animals' : '${item.count} animals',
                          style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${item.count}',
                              style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        ),
                        onTap: () => _showSheet(existing: item),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSheet(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
