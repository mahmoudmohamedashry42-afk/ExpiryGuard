class ProductModel {
  final String id;
  final String barcode;
  final String name;
  final String category; // القسم (مثال: أدوية، ألبان، عصائر)
  final String supplier; // المورد
  final String shelfLocation; // الرف/الموقع
  final String unit; // الوحدة (علبة، كرتونة، حبة)
  final double defaultPrice; // السعر التقديري
  final int minStockLevel; // الحد الأدنى للمخزون

  ProductModel({
    required this.id,
    required this.barcode,
    required this.name,
    required this.category,
    required this.supplier,
    required this.shelfLocation,
    required this.unit,
    required this.defaultPrice,
    this.minStockLevel = 10,
  });
}
