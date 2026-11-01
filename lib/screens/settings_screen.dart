import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enablePush = true;
  bool _enableEmailAlerts = true;
  bool _alert3Days = true;
  bool _alert7Days = true;
  bool _alert15Days = true;
  bool _alert30Days = true;
  String _selectedTimeZone = 'الرياض (GMT+3)';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات وقواعد التنبيه')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user?.name ?? 'المستخدم',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${user?.email}\nالدور: ${user?.role.displayName}',
                ),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'خروج',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    provider.logout();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Alert Threshold Rules Section
            const Text(
              'قواعد ومواعيد إطلاق التنبيهات (Alert Rules)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'تنبيه فوري قبل الانتهاء بـ 3 أيام (حرج)',
                    ),
                    subtitle: const Text(
                      'إطلاق تنبيه عالي الأهمية بلون برتقالي فاتح',
                    ),
                    value: _alert3Days,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) => setState(() => _alert3Days = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('تنبيه قبل الانتهاء بـ 7 أيام'),
                    subtitle: const Text(
                      'التشجيع على النشر في سوق B2B أو تطبيق تخفيض',
                    ),
                    value: _alert7Days,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) => setState(() => _alert7Days = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('تنبيه قبل الانتهاء بـ 15 يوماً'),
                    value: _alert15Days,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) => setState(() => _alert15Days = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'تنبيه قبل الانتهاء بـ 30 يوماً (قريب الانتهاء)',
                    ),
                    value: _alert30Days,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) => setState(() => _alert30Days = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification Channels
            const Text(
              'قنوات إرسال الإشعارات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'الإشعارات المباشرة على الجهاز (Push Notifications)',
                    ),
                    value: _enablePush,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) => setState(() => _enablePush = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'التقارير والإشعارات عبر البريد الإلكتروني',
                    ),
                    value: _enableEmailAlerts,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: (val) =>
                        setState(() => _enableEmailAlerts = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // System Preferences
            const Text(
              'تفضيلات النظام والمنطقة الزمنية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedTimeZone,
                      decoration: const InputDecoration(
                        labelText: 'المنطقة الزمنية لحساب التواريخ',
                        prefixIcon: Icon(Icons.public),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'الرياض (GMT+3)',
                          child: Text('الرياض (GMT+3)'),
                        ),
                        DropdownMenuItem(
                          value: 'دبي (GMT+4)',
                          child: Text('دبي (GMT+4)'),
                        ),
                        DropdownMenuItem(
                          value: 'القاهرة (GMT+2)',
                          child: Text('القاهرة (GMT+2)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTimeZone = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.language, color: AppTheme.primaryTeal),
                        SizedBox(width: 8),
                        Text(
                          'اللغة والواجهة: العربية (RTL كامل)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
