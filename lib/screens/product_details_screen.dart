import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  final BatchModel batch;

  const ProductDetailsScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Get all movements for this batch
    final movements = provider.movements
        .where(
          (m) => m.batchId == batch.id || m.productName == batch.productName,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(batch.productName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          batch.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: batch.statusBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: batch.statusColor),
                          ),
                          child: Text(
                            batch.statusText,
                            style: TextStyle(
                              color: batch.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('رقم البار كود:', batch.barcode),
                    _buildInfoRow('رقم التشغيلة (Batch):', batch.batchNumber),
                    _buildInfoRow('القسم / الفئة:', batch.category),
                    _buildInfoRow('المورد:', batch.supplier),
                    _buildInfoRow(
                      'تاريخ الانتهاء:',
                      '${batch.expiryDate.toString().split(' ')[0]} (باقي ${batch.remainingDays} يوم)',
                    ),
                    _buildInfoRow('الكمية الحالية:', '${batch.quantity} عبوة'),
                    _buildInfoRow('موقع الرف:', batch.shelfLocation),
                    _buildInfoRow(
                      'سعر القطعة:',
                      '${batch.unitPrice.toStringAsFixed(2)} جنيه',
                    ),
                    _buildInfoRow(
                      'إجمالي القيمة:',
                      '${(batch.quantity * batch.unitPrice).toStringAsFixed(2)} جنيه',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chronological Movements History Log
            const Row(
              children: [
                Icon(Icons.history_rounded, color: AppTheme.primaryTeal),
                SizedBox(width: 8),
                Text(
                  'سجل حركات وتدقيق المنتج (Audit Log / History)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            movements.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('لا توجد حركات سابقة مسجلة لهذه الدفعة بعد'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final mov = movements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryTeal.withValues(
                              alpha: 0.12,
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          title: Text(
                            '${mov.type.displayName} - كمية: ${mov.quantity > 0 ? "+${mov.quantity}" : mov.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'بواسطة: ${mov.userName} | ملاحظة: ${mov.note}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${mov.timestamp.hour}:${mov.timestamp.minute.toString().padLeft(2, '0')}\n${mov.timestamp.year}-${mov.timestamp.month}-${mov.timestamp.day}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
