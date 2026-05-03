class PredictedDriver {
  final int rank;
  final int driverId;
  final String driver;
  final String constructor;
  final double rankingScore;

  PredictedDriver({
    required this.rank,
    required this.driverId,
    required this.driver,
    required this.constructor,
    required this.rankingScore
});

  factory PredictedDriver.fromJson(Map<String, dynamic> json) {
    return PredictedDriver(
      rank: json["rank"] ?? 0,
      driverId: json["driverId"] ?? 0,
      driver: json["driver"] ?? "Unknown",
      constructor: json["constructor"] ?? "Unknown",
      rankingScore: (json["raning_score"] as num?)?.toDouble() ?? 0.0
    );
  }


}