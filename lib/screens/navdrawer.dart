import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Drawer(
      width: isDesktop ? 280 : null, // Adaptive width
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_filled,
                    label: "Home",
                    route: '/',
                  ),
                  _buildDivider(),
                  _buildNavItem(
                    context: context,
                    icon: Icons.settings,
                    label: "Settings",
                    route: '/setting',
                  ),
                  _buildDivider(),
                  _buildNavItem(
                    context: context,
                    icon: Icons.people_alt,
                    label: "About Us",
                    route: '/aboutus',
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: AssetImage("assets/images/download.jpg"),
          ),
          const SizedBox(height: 16),
          Text(
            "Abstractify",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "v0.1.6.8",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
      title: Text(label),
      trailing: currentRoute == route
          ? Icon(Icons.check, color: theme.colorScheme.primary, size: 18)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      horizontalTitleGap: 8,
      minLeadingWidth: 24,
      dense: true,
      selected: currentRoute == route,
      selectedColor: theme.colorScheme.primary,
      hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => _handleNavigation(context, route),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 24, endIndent: 24);
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            "© 2024 Abstractify",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            "All rights reserved",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    try {
      // Close drawer first
      Navigator.pop(context);

      // Check if we're already on the target route
      if (ModalRoute.of(context)?.settings.name == route) return;

      // Navigate using pushNamed to maintain stack
      Navigator.pushNamed(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Navigation error: ${e.toString()}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}