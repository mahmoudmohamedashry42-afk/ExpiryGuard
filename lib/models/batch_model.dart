import 'package:flutter/material.dart';

enum ExpiryStatus { expired, expiresToday, critical, nearExpiry, safe }

class BatchModel {
  final String id;
  final String productId;
  final String productName;
  final String barcode;
  final String category;
  final String supplier;
  final String batchNumber; // رقم التشغيلة/الدفعة
  final DateTime expiryDate;
  int quantity;
  final String shelfLocation;
  final String branchId;
  final String branchName;
  final double unitPrice;

  BatchModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.category,
    required this.supplier,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.shelfLocation,
    required this.branchId,
    required this.branchName,
    required this.unitPrice,
  });

  // Calculate remaining days relative to today (at midnight)
  int get remainingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // Exact rule calculation from document section 5
  ExpiryStatus get status {
    final days = remainingDays;
    if (days < 0) {
      return ExpiryStatus.expired;
    } else if (days == 0) {
      return ExpiryStatus.expiresToday;
    } else if (days >= 1 && days <= 3) {
      return ExpiryStatus.critical;
    } else if (days >= 4 && days <= 30) {
      return ExpiryStatus.nearExpiry;
    } else {
      return ExpiryStatus.safe;
    }
  }

  // Colors as specified in document section 5
  Color get statusColor {
    switch (status) {
      case ExpiryStatus.expired:
        return const Color(0xFFD32F2F); // أحمر منتهي
      case ExpiryStatus.expiresToday:
        return const Color(0xFFE65100); // برتقالي غامق ينتهي اليوم
      case ExpiryStatus.critical:
        return const Color(0xFFF57C00); // برتقالي فاتح حرج (1-3 أيام)
      case ExpiryStatus.nearExpiry:
        return const Color(0xFF1976D2); // أزرق قريب من الانتهاء (4-30 يوم)
      case ExpiryStatus.safe:
        return const Color(0xFF388E3C); // أخضر آمن (أكثر من 30 يوم)
    }
  }

  Color get statusBackgroundColor {
    return statusColor.withValues(alpha: 0.12);
  }

  String get statusText {
    switch (status) {
      case ExpiryStatus.expired:
        return 'منتهي الصلاحية';
      case ExpiryStatus.expiresToday:
        return 'ينتهي اليوم';
      case ExpiryStatus.critical:
        return 'حرج (خلال 1-3 أيام)';
      case ExpiryStatus.nearExpiry:
        return 'قريب الانتهاء ($remainingDays يوم)';
      case ExpiryStatus.safe:
        return 'آمن ($remainingDays يوم)';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ExpiryStatus.expired:
        return Icons.cancel_outlined;
      case ExpiryStatus.expiresToday:
        return Icons.error_outline;
      case ExpiryStatus.critical:
        return Icons.warning_amber_rounded;
      case ExpiryStatus.nearExpiry:
        return Icons.access_time_rounded;
      case ExpiryStatus.safe:
        return Icons.check_circle_outline;
    }
  }

  // Is blocked from listing on B2B
  bool get canListOnB2B => status != ExpiryStatus.expired;
}
