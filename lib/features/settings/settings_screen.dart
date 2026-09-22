import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/services/xml_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _export(ExportTable table) async {
    setState(() => _busy = true);
    try {
      await XmlService.exportAndShare(table);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final result = await XmlService.importFromFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Appearance ────────────────────────────────────────────
              const _SectionHeader(title: 'Appearance'),
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    themeProvider.isDark ? 'Currently using dark theme' : 'Currently using light theme',
                    style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: themeProvider.isDark,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => themeProvider.toggle(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Export ────────────────────────────────────────────────
              const _SectionHeader(title: 'Export Database (XML)'),
              Text(
                'Export data from this device to share or back up. '
                'You can import the file on another device (Android or Desktop) '
                'to transfer your records.',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _ExportTile(
                      icon: Icons.people_outline,
                      label: 'Export Contacts',
                      subtitle: 'Contacts table only',
                      color: AppColors.info,
                      onTap: _busy ? null : () => _export(ExportTable.contacts),
                    ),
                    const Divider(height: 1, indent: 56),
                    _ExportTile(
                      icon: Icons.trending_up_outlined,
                      label: 'Export Leads',
                      subtitle: 'Leads table only',
                      color: AppColors.secondary,
                      onTap: _busy ? null : () => _export(ExportTable.leads),
                    ),
                    const Divider(height: 1, indent: 56),
                    _ExportTile(
                      icon: Icons.receipt_outlined,
                      label: 'Export Invoices',
                      subtitle: 'Invoices table only',
                      color: AppColors.primaryLight,
                      onTap: _busy ? null : () => _export(ExportTable.invoices),
                    ),
                    const Divider(height: 1, indent: 56),
                    _ExportTile(
                      icon: Icons.storage_outlined,
                      label: 'Export All Tables',
                      subtitle: 'Contacts + Leads + Invoices in one file',
                      color: AppColors.primary,
                      onTap: _busy ? null : () => _export(ExportTable.all),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Import ────────────────────────────────────────────────
              const _SectionHeader(title: 'Import Database (XML)'),
              Text(
                'Pick an XML file previously exported from Meadowbrook ERP. '
                'Existing records with the same ID will be updated; new records '
                'will be added.',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _import,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Choose XML File to Import'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── About ─────────────────────────────────────────────────
              const _SectionHeader(title: 'About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.agriculture, color: AppColors.primary),
                      title: Text('Meadowbrook ERP', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                      subtitle: Text('Version 1.0.0', style: GoogleFonts.lato(fontSize: 12)),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.storage_outlined, color: AppColors.textSecondary),
                      title: Text('Database', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                      subtitle: Text('Local SQLite — stored on this device', style: GoogleFonts.lato(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_busy)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ExportTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.lato(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.share_outlined, size: 18, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
