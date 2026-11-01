import 'package:flutter/material.dart';

import '../models/audit_log_model.dart';
import '../models/batch_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/market_listing_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class AppProvider with ChangeNotifier {
  // Current user
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Registered users list
  final List<UserModel> _registeredUsers = [];
  List<UserModel> get registeredUsers => List.unmodifiable(_registeredUsers);

  // Base Products
  final List<ProductModel> _products = [];
  List<ProductModel> get products => List.unmodifiable(_products);

  // Batches
  final List<BatchModel> _batches = [];
  List<BatchModel> get batches => List.unmodifiable(_batches);

  // Movements
  final List<InventoryMovementModel> _movements = [];
  List<InventoryMovementModel> get movements => List.unmodifiable(_movements);

  // B2B Listings
  final List<MarketListingModel> _b2bListings = [];
  List<MarketListingModel> get b2bListings => List.unmodifiable(_b2bListings);

  // Audit Logs
  final List<AuditLogModel> _auditLogs = [];
  List<AuditLogModel> get auditLogs => List.unmodifiable(_auditLogs);

  // Search & Filter state
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedStatus =
      'الكل'; // الكل، منتهي، ينتهي اليوم، حرج، قريب الانتهاء، آمن
  String _selectedBranch = 'الكل';
  String _selectedSupplier = 'الكل';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get selectedBranch => _selectedBranch;
  String get selectedSupplier => _selectedSupplier;

  AppProvider() {
    _initSeedData();
    _currentUser = null;
    _isLoggedIn = false;
  }

  void _initSeedData() {
    // Start with empty inventory, products, batches, listings, and logs per user request ("شيل كل المنتجات")
    _products.clear();
    _batches.clear();
    _movements.clear();
    _b2bListings.clear();
    _auditLogs.clear();
  }

  // Authentication
  void login(String email, String password) {
    UserModel? user;
    try {
      user = _registeredUsers.firstWhere(
        (UserModel u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email.trim(),
        role: email.toLowerCase().contains('admin')
            ? UserRole.admin
            : UserRole.employee,
        branchId: 'b1',
        branchName: 'فرع المتجر الرئيسي',
      );
      _registeredUsers.add(user);
    }
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void registerNewUser(UserModel user) {
    _registeredUsers.add(user);
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void switchUserRole(UserRole role) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: role,
        branchId: _currentUser!.branchId,
        branchName: _currentUser!.branchName,
      );
    } else {
      _currentUser = UserModel(
        id: 'u_default',
        name: role == UserRole.admin ? 'مدير النظام' : 'موظف المخزون',
        email: role == UserRole.admin
            ? 'admin@store.com'
            : 'employee@store.com',
        role: role,
        branchId: 'b1',
        branchName: 'فرع المتجر الرئيسي',
      );
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSupplierFilter(String supplier) {
    _selectedSupplier = supplier;
    notifyListeners();
  }

  void setBranchFilter(String branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'الكل';
    _selectedStatus = 'الكل';
    _selectedBranch = 'الكل';
    _selectedSupplier = 'الكل';
    notifyListeners();
  }

  // Filtered Batches
  List<BatchModel> get filteredBatches {
    return _batches.where((batch) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = batch.productName.toLowerCase().contains(q);
        final matchesBarcode = batch.barcode.contains(q);
        final matchesBatchNum = batch.batchNumber.toLowerCase().contains(q);
        final matchesSupplier = batch.supplier.toLowerCase().contains(q);
        if (!matchesName &&
            !matchesBarcode &&
            !matchesBatchNum &&
            !matchesSupplier) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'الكل' && batch.category != _selectedCategory) {
        return false;
      }

      // Supplier filter
      if (_selectedSupplier != 'الكل' && batch.supplier != _selectedSupplier) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'الكل') {
        if (_selectedStatus == 'منتهي' &&
            batch.status != ExpiryStatus.expired) {
          return false;
        }
        if (_selectedStatus == 'ينتهي اليوم' &&
            batch.status != ExpiryStatus.expiresToday) {
          return false;
        }
        if (_selectedStatus == 'حرج' && batch.status != ExpiryStatus.critical) {
          return false;
        }
        if (_selectedStatus == 'قريب الانتهاء' &&
            batch.status != ExpiryStatus.nearExpiry) {
          return false;
        }
        if (_selectedStatus == 'آمن' && batch.status != ExpiryStatus.safe) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Stats getters
  int get countExpired =>
      _batches.where((b) => b.status == ExpiryStatus.expired).length;
  int get countExpiresToday =>
      _batches.where((b) => b.status == ExpiryStatus.expiresToday).length;
  int get countCritical =>
      _batches.where((b) => b.status == ExpiryStatus.critical).length;
  int get countNearExpiry =>
      _batches.where((b) => b.status == ExpiryStatus.nearExpiry).length;
  int get countSafe =>
      _batches.where((b) => b.status == ExpiryStatus.safe).length;

  double get totalInventoryValue {
    return _batches.fold(0.0, (sum, b) => sum + (b.quantity * b.unitPrice));
  }

  double get totalExpiredValue {
    return _batches
        .where((b) => b.status == ExpiryStatus.expired)
        .fold(0.0, (sum, b) => sum + (b.quantity * b.unitPrice));
  }

  double get totalCriticalValue {
    return _batches
        .where(
          (b) =>
              b.status == ExpiryStatus.critical ||
              b.status == ExpiryStatus.expiresToday,
        )
        .fold(0.0, (sum, b) => sum + (b.quantity * b.unitPrice));
  }

  // Actions on Batches

  // 1. Add Batch
  void addBatch({
    required String barcode,
    required String productName,
    required String category,
    required String supplier,
    required String batchNumber,
    required DateTime expiryDate,
    required int quantity,
    required String shelfLocation,
    required double unitPrice,
  }) {
    // Find or create product
    var product = _products.firstWhere(
      (p) => p.barcode == barcode || p.name == productName,
      orElse: () {
        final newP = ProductModel(
          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
          barcode: barcode,
          name: productName,
          category: category,
          supplier: supplier,
          shelfLocation: shelfLocation,
          unit: 'عبوة',
          defaultPrice: unitPrice,
        );
        _products.add(newP);
        return newP;
      },
    );

    final newBatch = BatchModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: productName,
      barcode: barcode,
      category: category,
      supplier: supplier,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      quantity: quantity,
      shelfLocation: shelfLocation,
      branchId: _currentUser?.branchId ?? 'b1',
      branchName: _currentUser?.branchName ?? 'الفرع الرئيسي',
      unitPrice: unitPrice,
    );

    _batches.add(newBatch);

    // Audit & Movement
    _recordMovement(
      batchId: newBatch.id,
      productName: productName,
      type: MovementType.addBatch,
      quantity: quantity,
      note: 'إضافة دفعة جديدة برقم $batchNumber',
    );

    _recordAuditLog(
      action: 'إضافة دفعة',
      entityName: productName,
      entityId: newBatch.id,
      details:
          'إضافة دفعة كمية $quantity بتاريخ انتهائها ${expiryDate.toString().split(' ')[0]}',
    );

    notifyListeners();
  }

  // 2. Update Quantity
  void updateBatchQuantity(String batchId, int newQuantity, String reason) {
    final batchIndex = _batches.indexWhere((b) => b.id == batchId);
    if (batchIndex != -1) {
      final oldQty = _batches[batchIndex].quantity;
      _batches[batchIndex].quantity = newQuantity;

      _recordMovement(
        batchId: batchId,
        productName: _batches[batchIndex].productName,
        type: MovementType.editQuantity,
        quantity: newQuantity - oldQty,
        note: 'تعديل كمية ($oldQty -> $newQuantity) السبب: $reason',
      );

      _recordAuditLog(
        action: 'تعديل كمية',
        entityName: _batches[batchIndex].productName,
        entityId: batchId,
        details: 'تعديل الكمية من $oldQty إلى $newQuantity. السبب: $reason',
      );

      notifyListeners();
    }
  }

  // 3. Dispose Waste (إتلاف)
  void disposeBatch(String batchId, int disposeQty, String reason) {
    final batchIndex = _batches.indexWhere((b) => b.id == batchId);
    if (batchIndex != -1) {
      final batch = _batches[batchIndex];
      batch.quantity = (batch.quantity - disposeQty).clamp(0, 999999);

      _recordMovement(
        batchId: batchId,
        productName: batch.productName,
        type: MovementType.dispose,
        quantity: -disposeQty,
        note: 'تسجيل إتلاف كمية $disposeQty. السبب: $reason',
      );

      _recordAuditLog(
        action: 'تسجيل إتلاف',
        entityName: batch.productName,
        entityId: batchId,
        details:
            'إتلاف كمية $disposeQty بقيمة تقديرية ${(disposeQty * batch.unitPrice).toStringAsFixed(2)} جنيه. السبب: $reason',
      );

      notifyListeners();
    }
  }

  // 4. Transfer Batch to another Branch
  void transferBatch(String batchId, int transferQty, String targetBranch) {
    final batchIndex = _batches.indexWhere((b) => b.id == batchId);
    if (batchIndex != -1) {
      final batch = _batches[batchIndex];
      batch.quantity = (batch.quantity - transferQty).clamp(0, 999999);

      _recordMovement(
        batchId: batchId,
        productName: batch.productName,
        type: MovementType.transfer,
        quantity: -transferQty,
        note: 'تحويل كمية $transferQty إلى فرع: $targetBranch',
      );

      _recordAuditLog(
        action: 'نقل فرعي',
        entityName: batch.productName,
        entityId: batchId,
        details: 'تحويل $transferQty إلى $targetBranch',
      );

      notifyListeners();
    }
  }

  // 5. Publish to B2B Marketplace
  // STRICT RULE: Cannot publish expired products!
  String? publishToB2B({
    required String batchId,
    required int quantity,
    required double offerPrice,
    required String pickupConditions,
  }) {
    final batch = _batches.firstWhere((b) => b.id == batchId);

    // Document Rule Check: Block published expired items
    if (!batch.canListOnB2B) {
      return 'يمنع النظام منعاً باتاً نشر المنتجات المنتهية الصلاحية في سوق B2B التبادلي.';
    }

    if (quantity > batch.quantity) {
      return 'الكمية المطلوبة للنشر تتجاوز الكمية المتاحة في المخزون (${batch.quantity}).';
    }

    final listing = MarketListingModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      batchId: batchId,
      productName: batch.productName,
      barcode: batch.barcode,
      category: batch.category,
      quantity: quantity,
      expiryDate: batch.expiryDate,
      originalUnitPrice: batch.unitPrice,
      offerUnitPrice: offerPrice,
      sellerStoreName: 'صيدلية/سوبرماركت الأمل',
      sellerBranch: _currentUser?.branchName ?? 'الفرع الرئيسي',
      sellerContactPhone: '+966 50 123 4567',
      pickupConditions: pickupConditions,
      status: DealStatus.published,
      createdAt: DateTime.now(),
    );

    _b2bListings.add(listing);

    _recordMovement(
      batchId: batchId,
      productName: batch.productName,
      type: MovementType.publishB2B,
      quantity: quantity,
      note: 'نشر صفقة B2B بسعر $offerPrice جنيه للعبوة',
    );

    _recordAuditLog(
      action: 'نشر B2B',
      entityName: batch.productName,
      entityId: listing.id,
      details:
          'نشر $quantity عبوة في سوق التدوير الذكي B2B بسعر عرض $offerPrice جنيه',
    );

    notifyListeners();
    return null; // Success
  }

  // 6. Update B2B Deal status
  void updateB2BDealStatus(
    String listingId,
    DealStatus newStatus, {
    String? buyerName,
    String? buyerNote,
  }) {
    final index = _b2bListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final listing = _b2bListings[index];
      listing.status = newStatus;
      if (buyerName != null) listing.buyerStoreName = buyerName;
      if (buyerNote != null) listing.buyerNote = buyerNote;

      _recordAuditLog(
        action: 'تحديث صفقة B2B',
        entityName: listing.productName,
        entityId: listingId,
        details: 'تغيير حالة الصفقة إلى: ${newStatus.displayName}',
      );

      notifyListeners();
    }
  }

  // Private Helper methods
  void _recordMovement({
    required String batchId,
    required String productName,
    required MovementType type,
    required int quantity,
    required String note,
  }) {
    _movements.insert(
      0,
      InventoryMovementModel(
        id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
        batchId: batchId,
        productName: productName,
        type: type,
        quantity: quantity,
        timestamp: DateTime.now(),
        userId: _currentUser?.id ?? 'sys',
        userName: _currentUser?.name ?? 'النظام',
        note: note,
      ),
    );
  }

  void _recordAuditLog({
    required String action,
    required String entityName,
    required String entityId,
    required String details,
  }) {
    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        entityName: entityName,
        entityId: entityId,
        userId: _currentUser?.id ?? 'sys',
        userName: _currentUser?.name ?? 'النظام',
        timestamp: DateTime.now(),
        details: details,
      ),
    );
  }

  // CSV Report Generator for Admins
  String generateCsvReport() {
    final buffer = StringBuffer();
    buffer.writeln(
      'اسم المنتج,البار كود,القسم,المورد,رقم الدفعة,تاريخ الانتهاء,الكمية,سعر الوحدة,الحالة,الرف',
    );
    for (var b in _batches) {
      buffer.writeln(
        '"${b.productName}","${b.barcode}","${b.category}","${b.supplier}","${b.batchNumber}","${b.expiryDate.toString().split(' ')[0]}",${b.quantity},${b.unitPrice},"${b.statusText}","${b.shelfLocation}"',
      );
    }
    return buffer.toString();
  }
}
