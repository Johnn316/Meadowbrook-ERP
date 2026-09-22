import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/equipment_model.dart';

class EquipmentScreen extends StatefulWidget {
  final String farmId;
  final String farmName;
  const EquipmentScreen({super.key, required this.farmId, required this.farmName});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  List<EquipmentModel> _items = [];
  bool _loading = true;

  static const _conditions = ['Good', 'Fair', 'Needs Repair'];
  static const _types = ['Tractor', 'Irrigation', 'Sprayer', 'Plough', 'Harvester', 'Generator', 'Pump', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await AppDatabase.getEquipment(widget.farmId);
    setState(() => _loading = false);
  }

  Color _conditionColor(String c) {
    switch (c) {
      case 'Good': return AppColors.success;
      case 'Fair': return Colors.orange;
      case 'Needs Repair': return AppColors.error;
      default: return AppColors.textLight;
    }
  }

  void _showSheet({EquipmentModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type.isNotEmpty == true ? existing!.type : _types.first;
    String condition = existing?.condition ?? 'Good';

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
                  Text(existing == null ? 'Add Equipment' : 'Edit Equipment',
                      style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        final ok = await _confirmDelete(ctx, existing.name);
                        if (ok && ctx.mounted) {
                          await AppDatabase.deleteEquipment(existing.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _load();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Equipment name', prefixIcon: Icon(Icons.construction_outlined)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined), labelText: 'Type'),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setModal(() => type = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: condition,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.health_and_safety_outlined), labelText: 'Condition'),
                items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModal(() => condition = v!),
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
                  if (nameCtrl.text.trim().isEmpty) return;
                  final now = DateTime.now().toIso8601String();
                  if (existing == null) {
                    await AppDatabase.insertEquipment(EquipmentModel(
                      id: const Uuid().v4(),
                      farmId: widget.farmId,
                      name: nameCtrl.text.trim(),
                      type: type,
                      condition: condition,
                      notes: notesCtrl.text.trim(),
                      createdAt: now,
                    ));
                  } else {
                    await AppDatabase.updateEquipment(existing.copyWith(
                      name: nameCtrl.text.trim(),
                      type: type,
                      condition: condition,
                      notes: notesCtrl.text.trim(),
                    ));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: Text(existing == null ? 'Save Equipment' : 'Save Changes'),
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
        title: const Text('Delete Equipment'),
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
        title: Text('Equipment — ${widget.farmName}',
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
                      const Icon(Icons.agriculture_outlined, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('No equipment recorded', style: GoogleFonts.lato(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Tap + to add equipment', style: GoogleFonts.lato(color: AppColors.textLight, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    final color = _conditionColor(item.condition);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.construction, color: AppColors.primary, size: 20),
                        ),
                        title: Text(item.name, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                        subtitle: Text(item.type, style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item.condition,
                              style: GoogleFonts.lato(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
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
