import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpiryGuardApp());
}

class ExpiryGuardApp extends StatelessWidget {
  const ExpiryGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'ExpiryGuard - إدارة صلاحية المخزون',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: provider.isLoggedIn
                ? const MainNavigationShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
