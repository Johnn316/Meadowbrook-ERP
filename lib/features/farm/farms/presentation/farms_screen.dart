import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/farms_provider.dart';
import '../domain/farm_model.dart';
import 'farm_detail_screen.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({super.key});

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmsProvider>().loadFarms();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmsProvider>();
    final farms = provider.farms.where((f) {
      final q = _query.toLowerCase();
      return q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.county.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search farms…',
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
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : farms.isEmpty && _query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.agriculture_outlined,
                                size: 72, color: AppColors.textLight),
                            const SizedBox(height: 16),
                            Text(
                              'No farms yet',
                              style: GoogleFonts.merriweather(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first farm',
                              style: GoogleFonts.lato(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : farms.isEmpty
                        ? Center(
                            child: Text('No farms match "$_query"',
                                style: GoogleFonts.lato(color: AppColors.textSecondary)),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: farms.length,
                            itemBuilder: (context, index) {
                              final farm = farms[index];
                              return _FarmCard(
                                farm: farm,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FarmDetailScreen(farm: farm),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFarmSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Farm',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddFarmSheet(BuildContext context) {
    final nameController = TextEditingController();
    final acreageController = TextEditingController();
    final descController = TextEditingController();
    String selectedCounty = 'Nairobi';
    final provider = context.read<FarmsProvider>();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Farm',
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Farm name',
                    prefixIcon: Icon(Icons.agriculture_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCounty,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    labelText: 'County',
                  ),
                  items: AppConstants.kenyanCounties
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedCounty = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: acreageController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Acreage',
                    prefixIcon: Icon(Icons.landscape_outlined),
                    suffixText: 'acres',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Description / notes (optional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await provider.addFarm(
                      name: nameController.text.trim(),
                      county: selectedCounty,
                      acreage: double.tryParse(acreageController.text) ?? 0.0,
                      description: descController.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save Farm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── WIDGETS ──────────────────────────────────────────────────────────────────

class _FarmCard extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback onTap;

  const _FarmCard({required this.farm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.agriculture,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: GoogleFonts.merriweather(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          farm.county,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.landscape_outlined,
                            size: 13, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          '${farm.acreage % 1 == 0 ? farm.acreage.toInt() : farm.acreage} acres',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (farm.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        farm.description,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
