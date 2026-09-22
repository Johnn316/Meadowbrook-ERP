import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/farms_provider.dart';
import '../domain/farm_model.dart';
import '../../crops/presentation/crops_screen.dart';
import '../../livestock/presentation/livestock_screen.dart';
import '../../equipment/presentation/equipment_screen.dart';
import '../../finances/presentation/finances_screen.dart';

// ─── Kenya county centre coordinates ─────────────────────────────────────────

const _countyCoords = <String, List<double>>{
  'Baringo': [0.4690, 35.9670],
  'Bomet': [-0.7821, 35.3412],
  'Bungoma': [0.5635, 34.5606],
  'Busia': [0.4608, 34.1116],
  'Elgeyo Marakwet': [0.8000, 35.5667],
  'Embu': [-0.5300, 37.4500],
  'Garissa': [-0.4532, 39.6461],
  'Homa Bay': [-0.5273, 34.4571],
  'Isiolo': [0.3545, 37.5820],
  'Kajiado': [-2.0987, 36.7820],
  'Kakamega': [0.2827, 34.7519],
  'Kericho': [-0.3700, 35.2833],
  'Kiambu': [-1.0315, 36.8209],
  'Kilifi': [-3.5107, 39.9093],
  'Kirinyaga': [-0.6590, 37.3550],
  'Kisii': [-0.6817, 34.7660],
  'Kisumu': [-0.0917, 34.7680],
  'Kitui': [-1.3667, 38.0167],
  'Kwale': [-4.1741, 39.4502],
  'Laikipia': [0.3606, 36.7819],
  'Lamu': [-2.2686, 40.9020],
  'Machakos': [-1.5177, 37.2634],
  'Makueni': [-2.2593, 37.8940],
  'Mandera': [3.9366, 41.8670],
  'Marsabit': [2.3284, 37.9895],
  'Meru': [0.0500, 37.6493],
  'Migori': [-1.0634, 34.4731],
  'Mombasa': [-4.0435, 39.6682],
  "Murang'a": [-0.7167, 37.1500],
  'Nairobi': [-1.2921, 36.8219],
  'Nakuru': [-0.3031, 36.0800],
  'Nandi': [0.1836, 35.1239],
  'Narok': [-1.0817, 35.8694],
  'Nyandarua': [-0.1800, 36.3500],
  'Nyamira': [-0.5667, 34.9333],
  'Nyeri': [-0.4167, 36.9500],
  'Samburu': [1.2167, 36.9500],
  'Siaya': [-0.0612, 34.2881],
  'Taita Taveta': [-3.3167, 38.4833],
  'Tana River': [-1.2000, 39.6833],
  'Tharaka Nithi': [-0.3000, 37.9500],
  'Trans Nzoia': [1.0500, 35.0000],
  'Turkana': [3.1167, 35.5967],
  'Uasin Gishu': [0.5167, 35.2833],
  'Vihiga': [0.0833, 34.7167],
  'Wajir': [1.7471, 40.0573],
  'West Pokot': [1.6167, 35.1167],
};

// ─── Weather helpers ──────────────────────────────────────────────────────────

String _weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 3) return 'Partly cloudy';
  if (code <= 48) return 'Foggy';
  if (code <= 55) return 'Drizzle';
  if (code <= 65) return 'Rain';
  if (code <= 82) return 'Rain showers';
  if (code <= 86) return 'Snow showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

IconData _weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code <= 3) return Icons.wb_cloudy;
  if (code <= 48) return Icons.foggy;
  if (code <= 65) return Icons.grain;
  if (code <= 82) return Icons.water_drop;
  if (code <= 99) return Icons.thunderstorm;
  return Icons.cloud;
}

Color _weatherColor(int code) {
  if (code == 0) return const Color(0xFFF59E0B);
  if (code <= 3) return const Color(0xFF64B5F6);
  if (code <= 65) return const Color(0xFF78909C);
  return const Color(0xFF5C6BC0);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FarmDetailScreen extends StatefulWidget {
  final FarmModel farm;
  const FarmDetailScreen({super.key, required this.farm});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  late FarmModel _farm;
  bool _weatherLoading = true;
  String? _weatherError;
  Map<String, dynamic>? _current;
  List<Map<String, dynamic>> _daily = [];

  @override
  void initState() {
    super.initState();
    _farm = widget.farm;
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
    });
    final coords = _countyCoords[_farm.county] ?? _countyCoords['Nairobi']!;
    final lat = coords[0];
    final lon = coords[1];
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=Africa%2FNairobi&forecast_days=7',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final cur = data['current'] as Map<String, dynamic>;
        final daily = data['daily'] as Map<String, dynamic>;
        final days = <Map<String, dynamic>>[];
        final count = (daily['time'] as List).length;
        for (var i = 0; i < count; i++) {
          days.add({
            'time': daily['time'][i],
            'code': daily['weather_code'][i] as int,
            'max': (daily['temperature_2m_max'][i] as num).toDouble(),
            'min': (daily['temperature_2m_min'][i] as num).toDouble(),
          });
        }
        setState(() {
          _current = cur;
          _daily = days;
          _weatherLoading = false;
        });
      } else {
        setState(() {
          _weatherError = 'Could not load weather (${res.statusCode})';
          _weatherLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weatherError = 'No internet connection';
        _weatherLoading = false;
      });
    }
  }

  void _showEditSheet() {
    final nameCtrl = TextEditingController(text: _farm.name);
    final acreageCtrl = TextEditingController(
        text: _farm.acreage == 0 ? '' : _farm.acreage.toString());
    final descCtrl = TextEditingController(text: _farm.description);
    String county = _farm.county;
    final provider = context.read<FarmsProvider>();

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
                Text('Edit Farm',
                    style: GoogleFonts.merriweather(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Farm name',
                    prefixIcon: Icon(Icons.agriculture_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: county,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    labelText: 'County',
                  ),
                  items: AppConstants.kenyanCounties
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setModal(() => county = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: acreageCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Acreage',
                    prefixIcon: Icon(Icons.landscape_outlined),
                    suffixText: 'acres',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Description / notes (optional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final updated = _farm.copyWith(
                      name: nameCtrl.text.trim(),
                      county: county,
                      acreage: double.tryParse(acreageCtrl.text) ?? _farm.acreage,
                      description: descCtrl.text.trim(),
                    );
                    await provider.updateFarm(updated);
                    setState(() => _farm = updated);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      // Refresh weather if county changed
                      if (county != _farm.county) _fetchWeather();
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Farm'),
        content: Text('Delete "${_farm.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<FarmsProvider>().deleteFarm(_farm.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit farm',
                onPressed: _showEditSheet,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                tooltip: 'Delete farm',
                onPressed: _confirmDelete,
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const Icon(Icons.agriculture,
                        color: Colors.white54, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _farm.name,
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_farm.county}  •  '
                          '${_farm.acreage % 1 == 0 ? _farm.acreage.toInt() : _farm.acreage} acres',
                          style: GoogleFonts.lato(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_farm.description.isNotEmpty) ...[
                    const _SectionTitle('About'),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _farm.description,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _SectionTitle('Current Weather — ${_farm.county}'),
                  const SizedBox(height: 8),
                  _buildCurrentWeather(),
                  const SizedBox(height: 20),
                  const _SectionTitle('7-Day Forecast'),
                  const SizedBox(height: 8),
                  _buildForecast(),
                  const SizedBox(height: 20),
                  const _SectionTitle('Farm Records'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _ModuleButton(
                        icon: Icons.grass,
                        label: 'Crops',
                        color: AppColors.success,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CropsScreen(farmId: _farm.id, farmName: _farm.name),
                        )),
                      ),
                      _ModuleButton(
                        icon: Icons.pets,
                        label: 'Livestock',
                        color: AppColors.secondary,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => LivestockScreen(farmId: _farm.id, farmName: _farm.name),
                        )),
                      ),
                      _ModuleButton(
                        icon: Icons.construction,
                        label: 'Equipment',
                        color: AppColors.primaryLight,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => EquipmentScreen(farmId: _farm.id, farmName: _farm.name),
                        )),
                      ),
                      _ModuleButton(
                        icon: Icons.account_balance_wallet,
                        label: 'Finances',
                        color: AppColors.info,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FinancesScreen(farmId: _farm.id, farmName: _farm.name),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    if (_weatherLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_weatherError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: AppColors.textLight),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_weatherError!,
                        style:
                            GoogleFonts.lato(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _fetchWeather,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final temp = (_current!['temperature_2m'] as num).toDouble();
    final code = _current!['weather_code'] as int;
    final wind = (_current!['wind_speed_10m'] as num).toDouble();
    final humidity = (_current!['relative_humidity_2m'] as num).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _weatherColor(code).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_weatherIcon(code),
                  color: _weatherColor(code), size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${temp.toStringAsFixed(1)}°C',
                    style: GoogleFonts.merriweather(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _weatherDescription(code),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.air, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text('${wind.toStringAsFixed(0)} km/h',
                          style: GoogleFonts.lato(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.water_drop_outlined,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text('$humidity%',
                          style: GoogleFonts.lato(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textLight),
              onPressed: _fetchWeather,
              tooltip: 'Refresh weather',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecast() {
    if (_weatherLoading || _daily.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _daily.map((d) {
            final code = d['code'] as int;
            final max = d['max'] as double;
            final min = d['min'] as double;
            final date = DateTime.tryParse(d['time'] as String);
            final label = date != null
                ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
                    'Sun'][date.weekday - 1]
                : '—';
            return Expanded(
              child: Column(
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Icon(_weatherIcon(code),
                      color: _weatherColor(code), size: 20),
                  const SizedBox(height: 6),
                  Text('${max.toStringAsFixed(0)}°',
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text('${min.toStringAsFixed(0)}°',
                      style: GoogleFonts.lato(
                          fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.merriweather(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ModuleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
