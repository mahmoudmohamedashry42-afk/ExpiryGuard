class AuditLogModel {
  final String id;
  final String action; // إضافة، تعديل، بيع، نقل، إتلاف، نشر B2B
  final String entityName;
  final String entityId;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String details;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.entityName,
    required this.entityId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.details,
  });
}
