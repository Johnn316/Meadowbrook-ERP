import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/crm/contacts/presentation/contacts_screen.dart';
import '../../features/crm/invoices/presentation/invoices_screen.dart';
import '../../features/crm/leads/presentation/leads_screen.dart';
import '../../features/farm/farms/presentation/farms_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      screen: const DashboardScreen(),
    ),
    _NavItem(
      label: 'Contacts',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      screen: const ContactsScreen(),
    ),
    _NavItem(
      label: 'Leads',
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      screen: const LeadsScreen(),
    ),
    _NavItem(
      label: 'Invoices',
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      screen: const InvoicesScreen(),
    ),
    _NavItem(
      label: 'Farm',
      icon: Icons.agriculture_outlined,
      activeIcon: Icons.agriculture,
      screen: const FarmsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.agriculture, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Meadowbrook ERP',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Dark / Light mode toggle
          IconButton(
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
            onPressed: themeProvider.toggle,
          ),
          // Profile menu
          PopupMenuButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Drawer for desktop / tablet
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child:
                        Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Farm Manager',
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'admin@meadowbrook.ke',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Dashboard
            _DrawerNavItem(
              item: _navItems[0],
              isSelected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),

            const Divider(),

            // CRM Section
            const _DrawerSectionHeader(title: 'CRM'),
            ..._navItems.sublist(1, 4).asMap().entries.map((e) =>
                _DrawerNavItem(
                  item: e.value,
                  isSelected: _selectedIndex == e.key + 1,
                  onTap: () {
                    setState(() => _selectedIndex = e.key + 1);
                    Navigator.pop(context);
                  },
                )),

            const Divider(),

            // Farm Section
            const _DrawerSectionHeader(title: 'Farm Management'),
            _DrawerNavItem(
              item: _navItems[4],
              isSelected: _selectedIndex == 4,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),

            const Spacer(),
            const Divider(),

            // Theme toggle in drawer
            ListTile(
              leading: Icon(
                themeProvider.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              title: Text(
                themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
                style: GoogleFonts.lato(fontSize: 14),
              ),
              onTap: themeProvider.toggle,
            ),

            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              title: Text(
                'Version 1.0.0',
                style: GoogleFonts.lato(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),

      body: _navItems[_selectedIndex].screen,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}

class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isSelected ? item.activeIcon : item.icon,
        color: isSelected
            ? AppColors.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        item.label,
        style: GoogleFonts.lato(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
