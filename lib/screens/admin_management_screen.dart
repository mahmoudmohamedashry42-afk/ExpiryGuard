import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentUser = provider.currentUser;

    if (currentUser?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة النظام')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 64,
                color: AppTheme.statusExpired,
              ),
              const SizedBox(height: 16),
              const Text(
                'عذراً، هذه الشاشة مخصصة فقط لمدير النظام / المتجر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'دورك الحالي هو: (${currentUser?.role.displayName})',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة إدارة النظام والتقارير'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          indicatorColor: AppTheme.primaryTeal,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'التقارير والهدر'),
            Tab(icon: Icon(Icons.people), text: 'إدارة الموظفين'),
            Tab(icon: Icon(Icons.receipt_long), text: 'سجل التدقيق Audit Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Financial & Waste Reports
          _buildFinancialReportTab(provider),

          // Tab 2: Users & Roles Management
          _buildUsersManagementTab(provider),

          // Tab 3: Audit Log Timeline
          _buildAuditLogTab(provider),
        ],
      ),
    );
  }

  Widget _buildFinancialReportTab(AppProvider provider) {
    final totalVal = provider.totalInventoryValue;
    final expiredVal = provider.totalExpiredValue;
    final criticalVal = provider.totalCriticalValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص تقارير الهدر المالي والمخزون',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final cards = [
                _buildMetricCard(
                  'إجمالي المخزون',
                  '${totalVal.toStringAsFixed(2)} ج.م',
                  AppTheme.primaryTeal,
                  Icons.account_balance_wallet_outlined,
                ),
                _buildMetricCard(
                  'خسائر المنتهي',
                  '${expiredVal.toStringAsFixed(2)} ج.م',
                  AppTheme.statusExpired,
                  Icons.trending_down_rounded,
                ),
                _buildMetricCard(
                  'خطر المعرض للهدر',
                  '${criticalVal.toStringAsFixed(2)} ج.م',
                  AppTheme.statusCritical,
                  Icons.report_problem_outlined,
                ),
              ];

              if (isWide) {
                return Row(
                  children: cards
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: c,
                          ),
                        ),
                      )
                      .toList(),
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 8),
                        Expanded(child: cards[1]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: cards[2]),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تحليل نسب المخزون حسب الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    'مخزون آمن',
                    provider.countSafe,
                    provider.batches.length,
                    AppTheme.statusSafe,
                  ),
                  _buildProgressBar(
                    'قريب الانتهاء (4-30 يوم)',
                    provider.countNearExpiry,
                    provider.batches.length,
                    AppTheme.statusNearExpiry,
                  ),
                  _buildProgressBar(
                    'حرج (1-3 أيام)',
                    provider.countCritical,
                    provider.batches.length,
                    AppTheme.statusCritical,
                  ),
                  _buildProgressBar(
                    'منتهي الصلاحية',
                    provider.countExpired,
                    provider.batches.length,
                    AppTheme.statusExpired,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                '$count (${(pct * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            color: color,
            backgroundColor: color.withOpacity(0.15),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersManagementTab(AppProvider provider) {
    final users = provider.registeredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'لا توجد حسابات مسجلة حتى الآن',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'قم بإنشاء حساب جديد من صفحة تسجيل الدخول',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = provider.currentUser?.id == user.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.isAdmin
                  ? AppTheme.primaryTeal.withOpacity(0.15)
                  : Colors.blue.shade100,
              child: Icon(
                user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: user.isAdmin
                    ? AppTheme.primaryTeal
                    : Colors.blue.shade800,
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${user.email} | ${user.branchName}\nالدور: ${user.role.displayName}',
            ),
            isThreeLine: true,
            trailing: isSelected
                ? const Chip(
                    label: Text(
                      'المستخدم الحالي',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                    backgroundColor: Colors.greenAccent,
                  )
                : ElevatedButton(
                    onPressed: () {
                      provider.switchUserRole(user.role);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم التبديل إلى حساب (${user.name})'),
                        ),
                      );
                    },
                    child: const Text(
                      'تبديل إليه',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAuditLogTab(AppProvider provider) {
    final logs = provider.auditLogs;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.darkSlate,
              child: Icon(Icons.shield_outlined, color: Colors.white, size: 20),
            ),
            title: Text(
              '${log.action} - ${log.entityName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text('بواسطة: ${log.userName}\nالتفاصيل: ${log.details}'),
            isThreeLine: true,
            trailing: Text(
              '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}\n${log.timestamp.day}/${log.timestamp.month}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }
}
