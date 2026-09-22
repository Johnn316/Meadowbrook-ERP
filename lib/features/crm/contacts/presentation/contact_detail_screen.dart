import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/contacts_provider.dart';
import '../domain/contact_model.dart';

class ContactDetailScreen extends StatefulWidget {
  final ContactModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late ContactModel _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  void _showEditSheet(BuildContext context) {
    final nameController = TextEditingController(text: _contact.name);
    final phoneController = TextEditingController(text: _contact.phone);
    final emailController = TextEditingController(text: _contact.email);
    String selectedType = _contact.type;
    String selectedCounty = _contact.county;
    final provider = context.read<ContactsProvider>();

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
              Text(
                'Edit Contact',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Full name',
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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.contactTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCounty,
                dropdownColor: Theme.of(ctx).colorScheme.surface,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: AppConstants.kenyanCounties
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedCounty = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final updated = _contact.copyWith(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    type: selectedType,
                    county: selectedCounty,
                  );
                  await provider.updateContact(updated);
                  setState(() => _contact = updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Text(
                        _contact.name[0].toUpperCase(),
                        style: GoogleFonts.merriweather(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _contact.name,
                      style: GoogleFonts.merriweather(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _contact.type,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Info Card
                  _SectionCard(
                    title: 'Contact Information',
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: _contact.phone.isEmpty
                              ? 'Not provided'
                              : _contact.phone,
                        ),
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _contact.email.isEmpty
                              ? 'Not provided'
                              : _contact.email,
                        ),
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'County',
                          value: _contact.county.isEmpty
                              ? 'Not provided'
                              : _contact.county,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  _SectionCard(
                    title: 'Quick Actions',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ActionButton(
                          icon: Icons.phone,
                          label: 'Call',
                          color: AppColors.success,
                          onTap: () async {
                            final phone = _contact.phone.replaceAll(' ', '');
                            if (phone.isEmpty) return;
                            final uri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        _ActionButton(
                          icon: Icons.message,
                          label: 'SMS',
                          color: AppColors.info,
                          onTap: () async {
                            final phone = _contact.phone.replaceAll(' ', '');
                            if (phone.isEmpty) return;
                            final uri = Uri(scheme: 'sms', path: phone);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        _ActionButton(
                          icon: Icons.trending_up,
                          label: 'New Lead',
                          color: AppColors.secondary,
                          onTap: () {},
                        ),
                        _ActionButton(
                          icon: Icons.receipt,
                          label: 'Invoice',
                          color: AppColors.primaryLight,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit / Delete buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditSheet(context),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Contact'),
                                content: Text(
                                    'Delete "${_contact.name}"? This cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              context
                                  .read<ContactsProvider>()
                                  .deleteContact(_contact.id);
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
