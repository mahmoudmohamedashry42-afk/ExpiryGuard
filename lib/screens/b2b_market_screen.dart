import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market_listing_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class B2BMarketScreen extends StatefulWidget {
  const B2BMarketScreen({super.key});

  @override
  State<B2BMarketScreen> createState() => _B2BMarketScreenState();
}

class _B2BMarketScreenState extends State<B2BMarketScreen> {
  DealStatus? _selectedStatusFilter;

  void _showDealDetailsDialog(
    BuildContext context,
    MarketListingModel listing,
  ) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.storefront_rounded, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Expanded(child: Text('تفاصيل صفقة B2B (${listing.productName})')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disclaimer Notice Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'إخلاء مسؤولية قانوني: تخضع الصفقة لاشتراطات وهيئة الغذاء والدواء لنقل وتخزين المنتجات. تقع مسؤولية الفحص على المشتري.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'المتجر البائع: ${listing.sellerStoreName} (${listing.sellerBranch})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Contact Phone - Hidden until deal is accepted
              Row(
                children: [
                  const Text('هاتف التواصل: ', style: TextStyle(fontSize: 12)),
                  (listing.status == DealStatus.reserved ||
                          listing.status == DealStatus.completed)
                      ? Text(
                          listing.sellerContactPhone,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '🔒 مخفي حتى قبول الطلب',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8),

              Text('الكمية المعروضة: ${listing.quantity} عبوة'),
              Text(
                'تاريخ الانتهاء: ${listing.expiryDate.toString().split(' ')[0]} (باقي ${listing.remainingDays} يوم)',
              ),
              Text(
                'السعر الأصلي للقطعة: ${listing.originalUnitPrice.toStringAsFixed(2)} جنيه',
              ),
              Text(
                'سعر العرض للقطعة: ${listing.offerUnitPrice.toStringAsFixed(2)} جنيه (خصم ${listing.discountPercentage.toStringAsFixed(0)}%)',
              ),
              Text(
                'إجمالي قيمة الصفقة: ${listing.totalOfferValue.toStringAsFixed(2)} جنيه',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'شروط الاستلام والنقل:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                listing.pickupConditions,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),

          // Action buttons based on state & user role
          if (listing.status == DealStatus.published)
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('تقديم طلب حجز وشراء B2B'),
              onPressed: () {
                provider.updateB2BDealStatus(
                  listing.id,
                  DealStatus.reserved,
                  buyerName: user?.branchName ?? 'مجمع/صيدلية المشتري',
                  buyerNote: 'تم طلب الحجز والموافقة على شروط الاستلام',
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم تقديم طلب الشراء وحجز الصفقة! تم إظهار هاتف التواصل.',
                    ),
                    backgroundColor: AppTheme.statusSafe,
                  ),
                );
              },
            ),

          if (user?.isAdmin == true && listing.status == DealStatus.reserved)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('تأكيد واكتمال الصفقة (مكتمل)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusSafe,
              ),
              onPressed: () {
                provider.updateB2BDealStatus(listing.id, DealStatus.completed);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم تحديث الصفقة إلى مكتملة وتوثيق الحركة بنجاح!',
                    ),
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

    List<MarketListingModel> listings = provider.b2bListings;
    if (_selectedStatusFilter != null) {
      listings = listings
          .where((l) => l.status == _selectedStatusFilter)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('سوق التدوير الذكي B2B')),
      body: Column(
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.handshake_outlined,
                  color: Colors.blue.shade800,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'منصة تبادل المنتجات القريبة من الصلاحية بين الصيدليات والمتاجر',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'تقليل الهدر المالي وإتاحة خيارات التصريف التجاري تحت التغطية والنقل الآمن.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('الكل (${provider.b2bListings.length})'),
                    selected: _selectedStatusFilter == null,
                    onSelected: (val) {
                      setState(() {
                        _selectedStatusFilter = null;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  ...DealStatus.values.map((status) {
                    final isSelected = _selectedStatusFilter == status;
                    final count = provider.b2bListings
                        .where((l) => l.status == status)
                        .length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(
                        label: Text('${status.displayName} ($count)'),
                        selected: isSelected,
                        selectedColor: status.color.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? status.color : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedStatusFilter = status;
                            } else {
                              _selectedStatusFilter = null;
                            }
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Listings Grid/List
          Expanded(
            child: listings.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد صفقات B2B مطابقة في هذا الفلتر حالياً',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listing.productName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'البائع: ${listing.sellerStoreName} | ${listing.sellerBranch}',
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
                                      color: listing.status.color.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: listing.status.color,
                                      ),
                                    ),
                                    child: Text(
                                      listing.status.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: listing.status.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Deal Pricing & Expiry Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الكمية المعروضة',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          '${listing.quantity} عبوة',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تاريخ الانتهاء',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          '${listing.expiryDate.toString().split(' ')[0]} (${listing.remainingDays} يوم)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'سعر العرض / القطعة',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${listing.offerUnitPrice.toStringAsFixed(2)} جنيه',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${listing.originalUnitPrice.toStringAsFixed(2)})',
                                              style: TextStyle(
                                                fontSize: 11,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Action Button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'معاينة تفاصيل الصفقة والشروط',
                                  ),
                                  onPressed: () =>
                                      _showDealDetailsDialog(context, listing),
                                ),
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
}
