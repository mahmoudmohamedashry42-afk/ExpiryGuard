import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedFilterIndex =
      0; // 0: الكل, 1: منتهي, 2: حرج وينتهي اليوم, 3: قريب الانتهاء

  void _showDiscountDialog(BuildContext context, BatchModel batch) {
    final discountController = TextEditingController(text: '30');
    final newPrice = batch.unitPrice * 0.7;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تخفيض سعر المنتج (${batch.productName})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر الحالي: ${batch.unitPrice.toStringAsFixed(2)} جنيه'),
            Text(
              'تاريخ الانتهاء: ${batch.expiryDate.toString().split(' ')[0]} (باقي ${batch.remainingDays} يوم)',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'نسبة الخصم %',
                suffixText: '%',
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'السعر المخفض الجديد: ~${newPrice.toStringAsFixed(2)} جنيه',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تطبيق تخفيض الخصم على ${batch.productName} وسجل التخفيض بنجاح!',
                  ),
                  backgroundColor: AppTheme.statusSafe,
                ),
              );
            },
            child: const Text('تطبيق التخفيض'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, BatchModel batch) {
    final branchController = TextEditingController(text: 'فرع العليا - الرياض');
    final qtyController = TextEditingController(
      text: (batch.quantity ~/ 2).toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحويل فرعي لمنتج (${batch.productName})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: branchController,
              decoration: const InputDecoration(
                labelText: 'الفرع المستهدف للتحويل',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية المحولة',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                provider.transferBatch(batch.id, qty, branchController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل طلب التحويل بين الفروع بنجاح!'),
                    backgroundColor: AppTheme.statusSafe,
                  ),
                );
              }
            },
            child: const Text('تأكيد التحويل'),
          ),
        ],
      ),
    );
  }

  void _showDisposeDialog(BuildContext context, BatchModel batch) {
    final qtyController = TextEditingController(
      text: batch.quantity.toString(),
    );
    final reasonController = TextEditingController(
      text: 'انتهاء تاريخ الصلاحية وسوء التخزين',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppTheme.statusExpired),
            SizedBox(width: 8),
            Text('تسجيل إتلاف مخزون (Waste)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${batch.productName}'),
            Text('رقم الدفعة: ${batch.batchNumber}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية المراد إتلافها',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإتلاف والمعاينة',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusExpired,
            ),
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                provider.disposeBatch(batch.id, qty, reasonController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم تسجيل الإتلاف وتوثيقه في سجل الحركات Audit Log',
                    ),
                    backgroundColor: AppTheme.statusExpired,
                  ),
                );
              }
            },
            child: const Text('إتلاف وتوثيق الخسارة'),
          ),
        ],
      ),
    );
  }

  void _showPublishB2BDialog(BuildContext context, BatchModel batch) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // STRICT DOCUMENT RULE: Block published expired items!
    if (!batch.canListOnB2B) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.block_rounded,
                color: AppTheme.statusExpired,
                size: 28,
              ),
              SizedBox(width: 8),
              Text('حظر النشر في سوق B2B'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusExpired.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusExpired),
                ),
                child: const Text(
                  '⚠️ يمنع النظام منعاً باتاً نشر المنتجات المنتهية الصلاحية في سوق B2B التبادلي امتثالاً للوائح ونظام هيئة الغذاء والدواء.',
                  style: TextStyle(
                    color: AppTheme.statusExpired,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'منتج (${batch.productName}) منتهي الصلاحية منذ ${batch.remainingDays.abs()} يوم. الإجراء المتاح الوحيد هو (تسجيل الإتلاف).',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً، فهمت'),
            ),
          ],
        ),
      );
      return;
    }

    final qtyController = TextEditingController(
      text: batch.quantity.toString(),
    );
    final priceController = TextEditingController(
      text: (batch.unitPrice * 0.5).toStringAsFixed(2),
    );
    final conditionsController = TextEditingController(
      text: 'التسليم من مقر الصيدلية/المتجر مع التثبت من التبريد',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('نشر عرض في سوق B2B (${batch.productName})'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سعر الوحدة الأصلي: ${batch.unitPrice.toStringAsFixed(2)} جنيه',
              ),
              Text(
                'تاريخ الانتهاء: ${batch.expiryDate.toString().split(' ')[0]} (متبقي ${batch.remainingDays} يوم)',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الكمية المعروضة في B2B',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'سعر العرض للقطعة في B2B (ج.م)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: conditionsController,
                decoration: const InputDecoration(
                  labelText: 'شروط الاستلام والنقل',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.store),
            label: const Text('نشر الصفقة في B2B'),
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              final err = provider.publishToB2B(
                batchId: batch.id,
                quantity: qty,
                offerPrice: price,
                pickupConditions: conditionsController.text,
              );

              Navigator.pop(ctx);

              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: AppTheme.statusExpired,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نشر العرض في سوق التدوير B2B بنجاح!'),
                    backgroundColor: AppTheme.statusSafe,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Filter & sort automatically from nearest to furthest expiry
    List<BatchModel> alertBatches = List<BatchModel>.from(provider.batches)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    if (_selectedFilterIndex == 1) {
      alertBatches = alertBatches
          .where((b) => b.status == ExpiryStatus.expired)
          .toList();
    } else if (_selectedFilterIndex == 2) {
      alertBatches = alertBatches
          .where(
            (b) =>
                b.status == ExpiryStatus.critical ||
                b.status == ExpiryStatus.expiresToday,
          )
          .toList();
    } else if (_selectedFilterIndex == 3) {
      alertBatches = alertBatches
          .where((b) => b.status == ExpiryStatus.nearExpiry)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مركز التنبيهات والمنتجات الحرجة')),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab(
                    0,
                    'جميع التنبيهات (${provider.batches.length})',
                    AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    1,
                    'منتهية الصلاحية (${provider.countExpired})',
                    AppTheme.statusExpired,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    2,
                    'حرجة / ينتهي اليوم (${provider.countCritical + provider.countExpiresToday})',
                    AppTheme.statusCritical,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    3,
                    'قريبة الانتهاء (${provider.countNearExpiry})',
                    AppTheme.statusNearExpiry,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // List of Critical Alert Batches
          Expanded(
            child: alertBatches.isEmpty
                ? const Center(
                    child: Text('لا توجد تنبيهات مطابقة للفلتر المحدد'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alertBatches.length,
                    itemBuilder: (context, index) {
                      final batch = alertBatches[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        batch.statusBackgroundColor,
                                    child: Icon(
                                      batch.statusIcon,
                                      color: batch.statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          batch.productName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'دفعة: ${batch.batchNumber} | الرف: ${batch.shelfLocation} | الكمية: ${batch.quantity}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: batch.statusBackgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: batch.statusColor.withOpacity(
                                          0.5,
                                        ),
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
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Quick Actions Row for each batch
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.sell_outlined,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'تخفيض السعر',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber.shade800,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showDiscountDialog(context, batch),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.compare_arrows_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'نقل فرعي',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade700,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showTransferDialog(context, batch),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.store_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'نشر في B2B',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: batch.canListOnB2B
                                          ? Colors.blue.shade800
                                          : Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showPublishB2BDialog(context, batch),
                                  ),
                                  OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      size: 16,
                                      color: AppTheme.statusExpired,
                                    ),
                                    label: const Text(
                                      'تسجيل إتلاف',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.statusExpired,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppTheme.statusExpired,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showDisposeDialog(context, batch),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String label, Color color) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.18),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? color : Colors.black87,
      ),
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
    );
  }
}
