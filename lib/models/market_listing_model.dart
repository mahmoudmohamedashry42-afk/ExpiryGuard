import 'package:flutter/material.dart';

enum DealStatus {
  published, // منشور
  underNegotiation, // قيد التفاوض
  reserved, // محجوز
  completed, // مكتمل
  cancelled, // ملغى
  expired, // منتهي
}

extension DealStatusExtension on DealStatus {
  String get displayName {
    switch (this) {
      case DealStatus.published:
        return 'منشور';
      case DealStatus.underNegotiation:
        return 'قيد التفاوض';
      case DealStatus.reserved:
        return 'محجوز';
      case DealStatus.completed:
        return 'مكتمل';
      case DealStatus.cancelled:
        return 'ملغى';
      case DealStatus.expired:
        return 'منتهي';
    }
  }

  Color get color {
    switch (this) {
      case DealStatus.published:
        return const Color(0xFF1976D2); // أزرق
      case DealStatus.underNegotiation:
        return const Color(0xFFED6C02); // برتقالي
      case DealStatus.reserved:
        return const Color(0xFF9C27B0); // بنفسجي
      case DealStatus.completed:
        return const Color(0xFF2E7D32); // أخضر
      case DealStatus.cancelled:
        return const Color(0xFF757575); // رمادي
      case DealStatus.expired:
        return const Color(0xFFD32F2F); // أحمر
    }
  }
}

class MarketListingModel {
  final String id;
  final String batchId;
  final String productName;
  final String barcode;
  final String category;
  final int quantity;
  final DateTime expiryDate;
  final double originalUnitPrice;
  final double offerUnitPrice; // سعر العرض في B2B
  final String sellerStoreName;
  final String sellerBranch;
  final String sellerContactPhone; // مخفي حتى قبول الصفقة
  final String pickupConditions; // شروط الاستلام والنقل
  DealStatus status;
  final DateTime createdAt;
  String? buyerStoreName;
  String? buyerNote;

  MarketListingModel({
    required this.id,
    required this.batchId,
    required this.productName,
    required this.barcode,
    required this.category,
    required this.quantity,
    required this.expiryDate,
    required this.originalUnitPrice,
    required this.offerUnitPrice,
    required this.sellerStoreName,
    required this.sellerBranch,
    required this.sellerContactPhone,
    required this.pickupConditions,
    this.status = DealStatus.published,
    required this.createdAt,
    this.buyerStoreName,
    this.buyerNote,
  });

  double get totalOriginalValue => quantity * originalUnitPrice;
  double get totalOfferValue => quantity * offerUnitPrice;
  double get discountPercentage =>
      ((originalUnitPrice - offerUnitPrice) / originalUnitPrice) * 100;

  int get remainingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}
