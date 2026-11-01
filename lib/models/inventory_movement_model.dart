enum MovementType {
  addBatch, // إضافة دفعة جديدة
  editQuantity, // تعديل كمية
  sell, // بيع
  transfer, // نقل بين الفروع
  dispose, // تسجيل إتلاف
  publishB2B; // نشر في سوق B2B

  String get displayName {
    switch (this) {
      case MovementType.addBatch:
        return 'إضافة دفعة';
      case MovementType.editQuantity:
        return 'تعديل كمية';
      case MovementType.sell:
        return 'عملية بيع';
      case MovementType.transfer:
        return 'نقل فرعي';
      case MovementType.dispose:
        return 'تسجيل إتلاف';
      case MovementType.publishB2B:
        return 'نشر B2B';
    }
  }
}

class InventoryMovementModel {
  final String id;
  final String batchId;
  final String productName;
  final MovementType type;
  final int quantity;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String note;

  InventoryMovementModel({
    required this.id,
    required this.batchId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.note,
  });
}
