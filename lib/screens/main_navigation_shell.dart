import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'admin_management_screen.dart';
import 'alerts_screen.dart';
import 'b2b_market_screen.dart';
import 'dashboard_screen.dart';
import 'inventory_list_screen.dart';
import 'scan_add_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    final screens = [
      DashboardScreen(onNavigateTab: _onItemTapped),
      const InventoryListScreen(),
      const ScanAddScreen(),
      const AlertsScreen(),
      const B2BMarketScreen(),
      if (user?.isAdmin == true)
        const AdminManagementScreen()
      else
        const SettingsScreen(),
      const SettingsScreen(),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            // Side NavigationRail for Large Screens / Tablets
            if (isWideScreen)
              NavigationRail(
                selectedIndex: _selectedIndex.clamp(0, screens.length - 1),
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: const IconThemeData(
                  color: AppTheme.primaryTeal,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppTheme.primaryTeal,
                        size: 36,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ExpiryGuard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('الرئيسية'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('المخزون'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.qr_code_scanner_outlined),
                    selectedIcon: Icon(Icons.qr_code_scanner),
                    label: Text('مسح وإضافة'),
                  ),
                  NavigationRailDestination(
                    icon: Badge(
                      label: Text(
                        '${provider.countExpired + provider.countCritical}',
                      ),
                      child: const Icon(Icons.notifications_active_outlined),
                    ),
                    selectedIcon: const Icon(Icons.notifications_active),
                    label: const Text('التنبيهات'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.storefront_outlined),
                    selectedIcon: Icon(Icons.storefront),
                    label: Text('سوق B2B'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(
                      user?.isAdmin == true
                          ? Icons.admin_panel_settings_outlined
                          : Icons.settings_outlined,
                    ),
                    selectedIcon: Icon(
                      user?.isAdmin == true
                          ? Icons.admin_panel_settings
                          : Icons.settings,
                    ),
                    label: Text(
                      user?.isAdmin == true ? 'الإدارة' : 'الإعدادات',
                    ),
                  ),
                ],
              ),
            if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),

            // Main Screen Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex.clamp(0, screens.length - 1),
                children: screens,
              ),
            ),
          ],
        ),

        // Bottom NavigationBar for Mobile
        bottomNavigationBar: !isWideScreen
            ? BottomNavigationBar(
                currentIndex: _selectedIndex.clamp(0, screens.length - 1),
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppTheme.primaryTeal,
                unselectedItemColor: Colors.grey.shade600,
                selectedFontSize: 11,
                unselectedFontSize: 10,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'الرئيسية',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2),
                    label: 'المخزون',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    activeIcon: Icon(Icons.add_circle_rounded),
                    label: 'إضافة',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      label: Text(
                        '${provider.countExpired + provider.countCritical}',
                      ),
                      child: const Icon(Icons.notifications_active_outlined),
                    ),
                    activeIcon: const Icon(Icons.notifications_active),
                    label: 'التنبيهات',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.storefront_outlined),
                    activeIcon: Icon(Icons.storefront),
                    label: 'سوق B2B',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      user?.isAdmin == true
                          ? Icons.admin_panel_settings_outlined
                          : Icons.settings_outlined,
                    ),
                    activeIcon: Icon(
                      user?.isAdmin == true
                          ? Icons.admin_panel_settings
                          : Icons.settings,
                    ),
                    label: user?.isAdmin == true ? 'الإدارة' : 'الإعدادات',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
