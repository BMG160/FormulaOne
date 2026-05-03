class MostImprovedDriver {
  final String driverName;
  final double avgPositionsGained;
  final double totalPositionsGained;
  final int races;

  MostImprovedDriver({
    required this.driverName,
    required this.avgPositionsGained,
    required this.totalPositionsGained,
    required this.races,
  });

  factory MostImprovedDriver.fromJson(Map<String, dynamic> json) {
    return MostImprovedDriver(
      driverName: json['driverName'],
      avgPositionsGained: (json['avg_positions_gained'] as num).toDouble(),
      totalPositionsGained: (json['total_positions_gained'] as num).toDouble(),
      races: json['races'] as int,
    );
  }
}