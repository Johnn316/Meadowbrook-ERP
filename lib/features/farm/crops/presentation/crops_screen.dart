import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/drift/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/crop_model.dart';

class CropsScreen extends StatefulWidget {
  final String farmId;
  final String farmName;
  const CropsScreen({super.key, required this.farmId, required this.farmName});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  List<CropModel> _crops = [];
  bool _loading = true;

  static const _statuses = ['Growing', 'Ready', 'Harvested'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _crops = await AppDatabase.getCrops(widget.farmId);
    setState(() => _loading = false);
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Growing': return AppColors.primary;
      case 'Ready': return AppColors.success;
      case 'Harvested': return AppColors.textSecondary;
      default: return AppColors.textLight;
    }
  }

  void _showSheet({CropModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final varietyCtrl = TextEditingController(text: existing?.variety ?? '');
    final plantingCtrl = TextEditingController(text: existing?.plantingDate ?? '');
    final harvestCtrl = TextEditingController(text: existing?.expectedHarvest ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String status = existing?.status ?? 'Growing';
    String crop = existing?.name ?? AppConstants.kenyanCrops.first;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(existing == null ? 'Add Crop' : 'Edit Crop',
                        style: GoogleFonts.merriweather(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    if (existing != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          final ok = await _confirmDelete(ctx, existing.name);
                          if (ok && ctx.mounted) {
                            await AppDatabase.deleteCrop(existing.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _load();
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: AppConstants.kenyanCrops.contains(crop) ? crop : AppConstants.kenyanCrops.first,
                  dropdownColor: Theme.of(ctx).colorScheme.surface,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.grass_outlined), labelText: 'Crop'),
                  items: AppConstants.kenyanCrops
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setModal(() { crop = v!; nameCtrl.text = v; }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: varietyCtrl,
                  decoration: const InputDecoration(hintText: 'Variety (optional)', prefixIcon: Icon(Icons.eco_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: plantingCtrl,
                  decoration: const InputDecoration(hintText: 'Planting date (e.g. 2024-03-01)', prefixIcon: Icon(Icons.calendar_today_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: harvestCtrl,
                  decoration: const InputDecoration(hintText: 'Expected harvest date', prefixIcon: Icon(Icons.event_available_outlined)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  dropdownColor: Theme.of(ctx).colorScheme.surface,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined), labelText: 'Status'),
                  items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setModal(() => status = v!),
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
                    final name = nameCtrl.text.trim().isEmpty ? crop : nameCtrl.text.trim();
                    final now = DateTime.now().toIso8601String();
                    if (existing == null) {
                      await AppDatabase.insertCrop(CropModel(
                        id: const Uuid().v4(),
                        farmId: widget.farmId,
                        name: name,
                        variety: varietyCtrl.text.trim(),
                        plantingDate: plantingCtrl.text.trim(),
                        expectedHarvest: harvestCtrl.text.trim(),
                        status: status,
                        notes: notesCtrl.text.trim(),
                        createdAt: now,
                      ));
                    } else {
                      await AppDatabase.updateCrop(existing.copyWith(
                        name: name,
                        variety: varietyCtrl.text.trim(),
                        plantingDate: plantingCtrl.text.trim(),
                        expectedHarvest: harvestCtrl.text.trim(),
                        status: status,
                        notes: notesCtrl.text.trim(),
                      ));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _load();
                  },
                  child: Text(existing == null ? 'Save Crop' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx, String name) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Delete Crop'),
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
        title: Text('Crops — ${widget.farmName}',
            style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _crops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grass, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('No crops recorded', style: GoogleFonts.lato(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Tap + to add a crop', style: GoogleFonts.lato(color: AppColors.textLight, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _crops.length,
                  itemBuilder: (_, i) {
                    final crop = _crops[i];
                    final color = _statusColor(crop.status);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(Icons.grass, color: color, size: 20),
                        ),
                        title: Text(crop.name,
                            style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [
                            if (crop.variety.isNotEmpty) crop.variety,
                            if (crop.plantingDate.isNotEmpty) 'Planted: ${crop.plantingDate}',
                          ].join(' · '),
                          style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(crop.status,
                              style: GoogleFonts.lato(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ),
                        onTap: () => _showSheet(existing: crop),
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
