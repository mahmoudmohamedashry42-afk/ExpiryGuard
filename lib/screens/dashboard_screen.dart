import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final batches = provider.batches;

    // Sort batches by expiry date (nearest first)
    final sortedBatches = List<BatchModel>.from(batches)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، ${user?.name ?? "المستخدم"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.branchName ?? 'الفرع الرئيسي',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Chip(
              avatar: Icon(
                user?.isAdmin == true
                    ? Icons.admin_panel_settings
                    : Icons.badge_outlined,
                size: 16,
                color: user?.isAdmin == true
                    ? AppTheme.primaryTeal
                    : Colors.blue.shade700,
              ),
              label: Text(
                user?.role.displayName ?? '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: user?.isAdmin == true
                      ? AppTheme.primaryTeal
                      : Colors.blue.shade700,
                ),
              ),
              backgroundColor: user?.isAdmin == true
                  ? AppTheme.primaryTeal.withOpacity(0.12)
                  : Colors.blue.shade50,
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh state if needed
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Grid
              _buildStatsGrid(context, provider),
              const SizedBox(height: 20),

              // Inventory Financial Overview
              _buildFinancialSummaryCard(context, provider),
              const SizedBox(height: 20),

              // Quick Action Buttons
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Nearest Expiring Products Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المنتجات الأكثر خطورة (أقرب انتهاءً)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkSlate,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (onNavigateTab != null)
                        onNavigateTab!(3); // Alerts tab
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Nearest Expiring Batches List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedBatches.take(4).length,
                itemBuilder: (context, index) {
                  final batch = sortedBatches[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: batch.statusBackgroundColor,
                        child: Icon(batch.statusIcon, color: batch.statusColor),
                      ),
                      title: Text(
                        batch.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'دفعة: ${batch.batchNumber} | الرف: ${batch.shelfLocation} | الكمية: ${batch.quantity}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: batch.statusBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: batch.statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          batch.statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: batch.statusColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AppProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.45,
          children: [
            _buildStatCard(
              title: 'منتهية الصلاحية',
              count: provider.countExpired,
              color: AppTheme.statusExpired,
              icon: Icons.cancel_outlined,
              subtitle: 'تتطلب إتلاف فوري',
            ),
            _buildStatCard(
              title: 'حرجة / ينتهي اليوم',
              count: provider.countCritical + provider.countExpiresToday,
              color: AppTheme.statusCritical,
              icon: Icons.warning_amber_rounded,
              subtitle: 'خلال 1-3 أيام',
            ),
            _buildStatCard(
              title: 'قريبة الانتهاء',
              count: provider.countNearExpiry,
              color: AppTheme.statusNearExpiry,
              icon: Icons.access_time_rounded,
              subtitle: 'خلال 4-30 يوم',
            ),
            _buildStatCard(
              title: 'مخزون آمن',
              count: provider.countSafe,
              color: AppTheme.statusSafe,
              icon: Icons.check_circle_outline,
              subtitle: 'أكثر من 30 يوم',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
    BuildContext context,
    AppProvider provider,
  ) {
    final totalVal = provider.totalInventoryValue;
    final expiredVal = provider.totalExpiredValue;
    final criticalVal = provider.totalCriticalValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تحليل الهدر والقيمة المالية للمخزون',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي قيمة المخزون',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalVal.toStringAsFixed(2)} جنيه',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قيمة الخسائر المنتهية',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expiredVal.toStringAsFixed(2)} جنيه',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusExpired,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قيمة الخطر المعرض للهدر',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${criticalVal.toStringAsFixed(2)} جنيه',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusCritical,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _buildActionButton(
        context,
        icon: Icons.qr_code_scanner_rounded,
        label: 'باركود',
        color: Colors.purple.shade700,
        onTap: () {
          if (onNavigateTab != null) onNavigateTab!(2);
        },
      ),
      _buildActionButton(
        context,
        icon: Icons.add_box_rounded,
        label: 'إضافة دفعة',
        color: AppTheme.primaryTeal,
        onTap: () {
          if (onNavigateTab != null) onNavigateTab!(2);
        },
      ),
      _buildActionButton(
        context,
        icon: Icons.warning_rounded,
        label: 'التنبيهات',
        color: Colors.amber.shade900,
        onTap: () {
          if (onNavigateTab != null) onNavigateTab!(3);
        },
      ),
      _buildActionButton(
        context,
        icon: Icons.store_rounded,
        label: 'سوق B2B',
        color: Colors.blue.shade800,
        onTap: () {
          if (onNavigateTab != null) onNavigateTab!(4);
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                children: actions.map((a) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: a))).toList(),
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: actions[0]),
                      const SizedBox(width: 8),
                      Expanded(child: actions[1]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: actions[2]),
                      const SizedBox(width: 8),
                      Expanded(child: actions[3]),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
