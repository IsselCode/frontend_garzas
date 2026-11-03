class UserStatistics {
  const UserStatistics({required this.activeUsers, required this.administrators,
    required this.sellers, required this.dispatchers, required this.salesDispatchers});
  final int activeUsers, administrators, sellers, dispatchers, salesDispatchers;
  factory UserStatistics.fromMap(Map<String, dynamic> map) => UserStatistics(
    activeUsers: (map['active_users'] as num).toInt(),
    administrators: (map['administrators'] as num).toInt(),
    sellers: (map['sellers'] as num).toInt(),
    dispatchers: (map['dispatchers'] as num).toInt(),
    salesDispatchers: (map['sales_dispatchers'] as num).toInt(),
  );
}
