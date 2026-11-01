import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ScanAddScreen extends StatefulWidget {
  const ScanAddScreen({super.key});

  @override
  State<ScanAddScreen> createState() => _ScanAddScreenState();
}

class _ScanAddScreenState extends State<ScanAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(
    text: 'أدوية ومستلزمات طبية',
  );
  final _supplierController = TextEditingController(
    text: 'شركة الدواء العربية',
  );
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController(text: '10');
  final _shelfController = TextEditingController(text: 'رف A-01');
  final _priceController = TextEditingController(text: '15.00');

  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 90));
  bool _isAutoMatched = false;

  final List<String> _categories = [
    'أدوية ومستلزمات طبية',
    'ألبان وأغذية طازجة',
    'مشروبات وعصائر',
    'زيوت ومواد غذائية',
    'مستحضرات تجميل ورعاية شخصية',
    'حلويات وسكاكر',
  ];

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _supplierController.dispose();
    _batchNumberController.dispose();
    _quantityController.dispose();
    _shelfController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onBarcodeScanned(String barcode) {
    setState(() {
      _barcodeController.text = barcode;
    });

    // Auto-match against existing database
    final provider = Provider.of<AppProvider>(context, listen: false);
    final match = provider.products.cast<dynamic>().firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => null,
    );

    if (match != null) {
      setState(() {
        _nameController.text = match.name;
        _categoryController.text = match.category;
        _supplierController.text = match.supplier;
        _shelfController.text = match.shelfLocation;
        _priceController.text = match.defaultPrice.toStringAsFixed(2);
        _batchNumberController.text =
            'LOT-${DateTime.now().year}-${DateTime.now().millisecond}';
        _isAutoMatched = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم العثور على المنتج تلقائياً: ${match.name}'),
          backgroundColor: AppTheme.statusSafe,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _isAutoMatched = false;
        _batchNumberController.text =
            'LOT-${DateTime.now().year}-${DateTime.now().millisecond}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بار كود جديد! يرجى إدخال تفاصيل المنتج الدفعة.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'اختر تاريخ انتهاء الصلاحية',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });

      // Warning prompt if date is in the past
      if (picked.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.statusExpired,
                ),
                SizedBox(width: 8),
                Text('تنبيه تاريخ منتهي'),
              ],
            ),
            content: const Text(
              'تاريخ انتهاء الصلاحية المختار في الماضي! هل أنت تأكد من إضافة هذه الدفعة كمنتج منتهي الصلاحية؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('موافق (إضافة لتسجيل الإتلاف)'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _saveBatch() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);

      final qty = int.tryParse(_quantityController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0.0;

      if (qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ: الكمية يجب أن تكون أكبر من 0'),
            backgroundColor: AppTheme.statusExpired,
          ),
        );
        return;
      }

      provider.addBatch(
        barcode: _barcodeController.text.trim().isEmpty
            ? 'BAR-${DateTime.now().millisecondsSinceEpoch}'
            : _barcodeController.text.trim(),
        productName: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        supplier: _supplierController.text.trim(),
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? 'LOT-${DateTime.now().millisecondsSinceEpoch}'
            : _batchNumberController.text.trim(),
        expiryDate: _selectedExpiryDate,
        quantity: qty,
        shelfLocation: _shelfController.text.trim(),
        unitPrice: price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الدفعة بنجاح (${_nameController.text})'),
          backgroundColor: AppTheme.statusSafe,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        _barcodeController.clear();
        _nameController.clear();
        _batchNumberController.clear();
        _isAutoMatched = false;
        _selectedExpiryDate = DateTime.now().add(const Duration(days: 90));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('مسح وإضافة دفعة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Centered Live Camera Scanner Box
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    color: Colors.grey.shade900,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.greenAccent,
                                size: 26,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'ماسح البار كود بالكاميرا الحية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 260,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: MobileScanner(
                                  onDetect: (capture) {
                                    final List<Barcode> barcodes = capture.barcodes;
                                    for (final barcode in barcodes) {
                                      if (barcode.rawValue != null) {
                                        _onBarcodeScanned(barcode.rawValue!);
                                        break;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_isAutoMatched)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تم التعرف على تماثل المنتج تلقائياً من قاعدة البيانات!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Barcode Input
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'رقم البار كود (Barcode)',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_barcodeController.text.isNotEmpty) {
                        _onBarcodeScanned(_barcodeController.text.trim());
                      }
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال أو مسح البار كود';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج الأساسي',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال اسم المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category & Supplier Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categories.contains(_categoryController.text)
                          ? _categoryController.text
                          : _categories[0],
                      decoration: const InputDecoration(
                        labelText: 'القسم / الفئة',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _categoryController.text = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _supplierController,
                      decoration: const InputDecoration(
                        labelText: 'المورد / الشركة',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Batch Number & Expiry Date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الدفعة / التشغيلة (Lot/Batch)',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال رقم الدفعة';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الانتهاء',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        child: Text(
                          '${_selectedExpiryDate.year}-${_selectedExpiryDate.month.toString().padLeft(2, '0')}-${_selectedExpiryDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quantity, Shelf Location & Unit Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الكمية (عدد العبوات)',
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      validator: (val) {
                        final num = int.tryParse(val ?? '');
                        if (num == null || num <= 0) {
                          return 'أدخل كمية صحيحة أكبر من 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _shelfController,
                      decoration: const InputDecoration(
                        labelText: 'موقع الرف / الثلاجة',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'سعر الوحدة (ج.م)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Action Button
              ElevatedButton.icon(
                onPressed: _saveBatch,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text(
                  'حفظ وإضافة الدفعة للمخزون',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
