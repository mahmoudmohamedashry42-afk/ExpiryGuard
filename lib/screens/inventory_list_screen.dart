import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'product_details_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'الكل',
    'منتهي',
    'ينتهي اليوم',
    'حرج',
    'قريب الانتهاء',
    'آمن',
  ];

  final List<String> _categoryOptions = [
    'الكل',
    'أدوية ومستلزمات طبية',
    'ألبان وأغذية طازجة',
    'مشروبات وعصائر',
    'زيوت ومواد غذائية',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditQuantityDialog(BuildContext context, BatchModel batch) {
    final qtyController = TextEditingController(
      text: batch.quantity.toString(),
    );
    final reasonController = TextEditingController(text: 'تعديل جرد دوري');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل كمية الدفعة (${batch.batchNumber})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${batch.productName}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية الجديدة',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب التعديل',
                prefixIcon: Icon(Icons.edit_note),
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
              final newQty = int.tryParse(qtyController.text);
              if (newQty != null && newQty >= 0) {
                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                provider.updateBatchQuantity(
                  batch.id,
                  newQty,
                  reasonController.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث الكمية والسجل بنجاح')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _exportCsvReport(BuildContext context, AppProvider provider) {
    final csv = provider.generateCsvReport();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_chart_rounded, color: AppTheme.primaryTeal),
            SizedBox(width: 8),
            Text('تصدير تقرير المخزون (CSV / Excel)'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تم تجهيز التقرير الشامل بتنسيق CSV للمدير:'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csv,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('تحميل التقرير'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تحميل ملف التقرير CSV بنجاح!'),
                  backgroundColor: AppTheme.statusSafe,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final batches = provider.filteredBatches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول وحصر المخزون'),
        actions: [
          if (user?.canExportReports() == true)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: AppTheme.primaryTeal,
              ),
              tooltip: 'تصدير CSV / Excel',
              onPressed: () => _exportCsvReport(context, provider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم، البار كود، رقم الدفعة، أو المورد...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    provider.setSearchQuery(val);
                  },
                ),
                const SizedBox(height: 12),

                // Filters Row (Category & Status)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'الحالة: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ..._statusOptions.map((status) {
                        final isSelected = provider.selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryTeal.withValues(
                              alpha: 0.18,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppTheme.primaryTeal
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              provider.setStatusFilter(status);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'القسم: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ..._categoryOptions.map((cat) {
                        final isSelected = provider.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppTheme.accentCyan.withValues(
                              alpha: 0.18,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.teal.shade900
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              provider.setCategoryFilter(cat);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Count Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد الدفعات المطابقة: ${batches.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (provider.selectedStatus != 'الكل' ||
                    provider.selectedCategory != 'الكل' ||
                    provider.searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          size: 16,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'إعادة ضبط الفلاتر',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Batches List or Empty State
          Expanded(
            child: batches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد دفعات مخزون مطابقة للبحث أو الفلتر الحالي',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: batches.length,
                    itemBuilder: (context, index) {
                      final batch = batches[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        const SizedBox(height: 4),
                                        Text(
                                          'بار كود: ${batch.barcode} | المورد: ${batch.supplier}',
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
                                        color: batch.statusColor.withValues(
                                          alpha: 0.5,
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
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDetailChip(
                                    Icons.numbers,
                                    'الدفعة:',
                                    batch.batchNumber,
                                  ),
                                  _buildDetailChip(
                                    Icons.calendar_month,
                                    'تاريخ الانتهاء:',
                                    batch.expiryDate.toString().split(' ')[0],
                                  ),
                                  _buildDetailChip(
                                    Icons.inventory_2_outlined,
                                    'الكمية:',
                                    '${batch.quantity} عبوة',
                                  ),
                                  _buildDetailChip(
                                    Icons.location_on_outlined,
                                    'الرف:',
                                    batch.shelfLocation,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text(
                                      'تعديل الكمية',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () =>
                                        _showEditQuantityDialog(context, batch),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'التفاصيل والسجل',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsScreen(
                                            batch: batch,
                                          ),
                                        ),
                                      );
                                    },
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

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 3),
        Text(
          '$label ',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkSlate,
          ),
        ),
      ],
    );
  }
}
