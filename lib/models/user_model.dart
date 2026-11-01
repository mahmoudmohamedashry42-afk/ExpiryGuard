enum UserRole {
  admin,
  employee;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام / المتجر';
      case UserRole.employee:
        return 'موظف المتجر';
    }
  }

  String get code {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.employee:
        return 'employee';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String branchId;
  final String branchName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchId,
    required this.branchName,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee;

  // Permissions check
  bool canManageUsers() => isAdmin;
  bool canViewFinancialReports() => isAdmin;
  bool canApproveDeals() => isAdmin;
  bool canCancelMovements() => isAdmin;
  bool canChangeSettings() => isAdmin;
  bool canExportReports() => isAdmin;

  bool canAddBatch() => true;
  bool canUpdateQuantity() => true;
  bool canViewAlerts() => true;
  bool canRequestTransfer() => true;
  bool canProposeDiscount() => true;
  bool canRequestDispose() => true;
}
