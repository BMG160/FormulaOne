import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xgboostranker_app/driver_page.dart';
import 'package:xgboostranker_app/constructor_page.dart';
import 'package:xgboostranker_app/search_item.dart';
import 'package:xgboostranker_app/data_agent.dart';
import 'package:xgboostranker_app/cloud_fire_store_impl.dart';
import 'firebase_options.dart';
import 'driver_comparison_page.dart';
import 'race_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

const String baseUrl = "http://10.0.2.2:8000";

class AppColors {
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF131A2E);
  static const surfaceLight = Color(0xFF1A223A);
  static const cardBorder = Color(0xFF2A3557);
  static const accent = Color(0xFFE10600);
  static const accentSoft = Color(0xFFFF5A52);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB8C1D9);
  static const gold = Color(0xFFFFC857);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: AppColors.cardBorder,
              width: 1,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SearchBottomSheet(),
    );
  }

  Widget _buildFeatureShortcuts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _featureCard(
              icon: Icons.compare_arrows_rounded,
              title: "Compare",
              subtitle: "Compare drivers",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverComparisonPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _featureCard(
              icon: Icons.history_rounded,
              title: "Race History",
              subtitle: "View results",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RaceHistoryPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accentSoft,
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openSearchSheet,
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.search_rounded),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF121A33),
                AppColors.background,
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E2A52),
                        Color(0xFF10182F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accentSoft,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.sports_motorsports_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "F1 Analytics",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "League predictions and driver performance insights",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFeatureShortcuts(context),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.accentSoft,
                        ],
                      ),
                    ),
                    tabs: [
                      Tab(text: "League Table"),
                      Tab(text: "Most Improved"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: TabBarView(
                    children: [
                      LeagueTablePage(),
                      MostImprovedDriversScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PredictedDriver {
  final int rank;
  final int driverId;
  final String driver;
  final int constructorId;
  final String constructor;
  final double rankingScore;

  PredictedDriver({
    required this.rank,
    required this.driverId,
    required this.driver,
    required this.constructorId,
    required this.constructor,
    required this.rankingScore,
  });

  factory PredictedDriver.fromJson(Map<String, dynamic> json) {
    return PredictedDriver(
      rank: json["rank"] ?? 0,
      driverId: json["driverId"] ?? 0,
      driver: json["driver"] ?? "Unknown Driver",
      constructorId: json["constructorId"] ?? 0,
      constructor: json["constructor"] ??
          json["constructor_name"] ??
          "Unknown Constructor",
      rankingScore: (json["ranking_score"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MostImprovedDriver {
  final int driverId;
  final String driverName;
  final int constructorId;
  final String constructor;
  final double avgPositionsGained;
  final double totalPositionsGained;
  final int races;

  MostImprovedDriver({
    required this.driverId,
    required this.driverName,
    required this.constructorId,
    required this.constructor,
    required this.avgPositionsGained,
    required this.totalPositionsGained,
    required this.races,
  });

  factory MostImprovedDriver.fromJson(Map<String, dynamic> json) {
    return MostImprovedDriver(
      driverId: json["driverId"] ?? 0,
      driverName: json["driverName"] ?? json["driver_name"] ?? "Unknown Driver",
      constructorId: json["constructorId"] ?? 0,
      constructor: json["constructor"] ??
          json["constructor_name"] ??
          json["constructorRef"] ??
          "Unknown Constructor",
      avgPositionsGained:
      (json["avg_positions_gained"] as num?)?.toDouble() ?? 0.0,
      totalPositionsGained:
      (json["total_positions_gained"] as num?)?.toDouble() ?? 0.0,
      races: json["races"] ?? 0,
    );
  }
}

class ApiService {
  static Future<List<PredictedDriver>> fetchPredictedLeagueTable() async {
    final url = Uri.parse("$baseUrl/predict-league-table");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded["data"] == null) {
        throw Exception("No data field found in API response");
      }

      final List data = decoded["data"];
      return data.map((e) => PredictedDriver.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load league table: ${response.body}");
    }
  }

  static Future<List<MostImprovedDriver>> fetchMostImprovedDrivers() async {
    final url = Uri.parse("$baseUrl/most-improved-drivers");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded["data"] == null) {
        throw Exception("No data field found in API response");
      }

      final List data = decoded["data"];
      return data.map((e) => MostImprovedDriver.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load improved drivers: ${response.body}");
    }
  }
}

class LeagueTablePage extends StatefulWidget {
  const LeagueTablePage({super.key});

  @override
  State<LeagueTablePage> createState() => _LeagueTablePageState();
}

class _LeagueTablePageState extends State<LeagueTablePage> {
  late Future<List<PredictedDriver>> futureDrivers;

  @override
  void initState() {
    super.initState();
    futureDrivers = ApiService.fetchPredictedLeagueTable();
  }

  Future<void> refreshData() async {
    setState(() {
      futureDrivers = ApiService.fetchPredictedLeagueTable();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: refreshData,
      child: FutureBuilder<List<PredictedDriver>>(
        future: futureDrivers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 260),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 120),
                _ErrorState(message: "Error loading league table"),
              ],
            );
          }

          final drivers = snapshot.data ?? [];

          if (drivers.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 120),
                _EmptyState(message: "No league table data found"),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: index == 0
                              ? [AppColors.gold, const Color(0xFFFFE39A)]
                              : [
                            AppColors.accent,
                            AppColors.accentSoft,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          driver.rank.toString(),
                          style: TextStyle(
                            color: index == 0 ? Colors.black : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverPage(
                                    id: driver.driverId.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              driver.driver,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.apartment_rounded,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ConstructorPage(
                                          id: driver.constructorId.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    driver.constructor,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _miniBadge("ID ${driver.driverId}"),
                              const SizedBox(width: 8),
                              _miniBadge("CID ${driver.constructorId}"),
                              const SizedBox(width: 8),
                              _miniBadge(
                                "Score ${driver.rankingScore.toStringAsFixed(4)}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MostImprovedDriversScreen extends StatefulWidget {
  const MostImprovedDriversScreen({super.key});

  @override
  State<MostImprovedDriversScreen> createState() =>
      _MostImprovedDriversScreenState();
}

class _MostImprovedDriversScreenState extends State<MostImprovedDriversScreen> {
  late Future<List<MostImprovedDriver>> futureDrivers;

  @override
  void initState() {
    super.initState();
    futureDrivers = ApiService.fetchMostImprovedDrivers();
  }

  Future<void> refreshData() async {
    setState(() {
      futureDrivers = ApiService.fetchMostImprovedDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: refreshData,
      child: FutureBuilder<List<MostImprovedDriver>>(
        future: futureDrivers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 250),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 120),
                _ErrorState(message: "Error loading improved drivers"),
              ],
            );
          }

          final drivers = snapshot.data;

          if (drivers == null || drivers.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 120),
                _EmptyState(message: "No data available"),
              ],
            );
          }

          final topDriver = drivers.first;
          final maxY = drivers
              .map((e) => e.avgPositionsGained)
              .reduce((a, b) => a > b ? a : b) +
              1;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2A1731),
                        Color(0xFF181F3A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 14,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gold,
                              Color(0xFFFFE39A),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Most Improved Driver',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              topDriver.driverName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _statChip(
                                  Icons.trending_up_rounded,
                                  'Avg ${topDriver.avgPositionsGained.toStringAsFixed(2)}',
                                ),
                                _statChip(
                                  Icons.bar_chart_rounded,
                                  'Total ${topDriver.totalPositionsGained.toStringAsFixed(0)}',
                                ),
                                _statChip(
                                  Icons.flag_circle_rounded,
                                  'Races ${topDriver.races}',
                                ),
                                _statChip(
                                  Icons.apartment_rounded,
                                  topDriver.constructor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Performance Chart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 420,
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.08),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 86,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 || index >= drivers.length) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 10,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    drivers[index].driverName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        drivers.length,
                            (index) {
                          final driver = drivers[index];

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: driver.avgPositionsGained,
                                width: 18,
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentSoft,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Driver Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...drivers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final driver = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.surfaceLight,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverPage(
                                        id: driver.driverId.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  driver.driverName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.apartment_rounded,
                                    color: AppColors.textSecondary,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConstructorPage(
                                                  id: driver.constructorId
                                                      .toString(),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Constructor: ${driver.constructor}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Driver ID: ${driver.driverId}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Avg gained: ${driver.avgPositionsGained.toStringAsFixed(2)}  •  Total: ${driver.totalPositionsGained.toStringAsFixed(0)}  •  Races: ${driver.races}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  String query = "";
  bool isLoading = false;
  List<SearchItem> results = [];

  final List<String> quickSearches = [
    "Hamilton",
    "Verstappen",
    "Ferrari",
    "McLaren",
    "Mercedes",
  ];

  Future<void> _performSearch(String value) async {
    final trimmed = value.trim();

    setState(() {
      query = trimmed;
    });

    if (trimmed.isEmpty) {
      setState(() {
        results = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      DataAgent agent = CloudFireStoreImpl();
      final searchResults = await agent.searchAll(trimmed);

      if (!mounted) return;

      setState(() {
        results = searchResults;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        results = [];
        isLoading = false;
      });
    }
  }

  void _openResult(SearchItem item) {
    Navigator.pop(context);

    if (item.type == 'driver') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DriverPage(id: item.id),
        ),
      );
    } else if (item.type == 'constructor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConstructorPage(id: item.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Search",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Search drivers or constructors",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              onChanged: _performSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a driver or constructor name",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    _performSearch('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (query.isEmpty) ...[
              const Text(
                "Quick Search",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: quickSearches.map((item) {
                  return GestureDetector(
                    onTap: () {
                      _controller.text = item;
                      _performSearch(item);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
            ],
            const Text(
              "Results",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              )
                  : query.isEmpty
                  ? const Center(
                child: Text(
                  "Start typing to search",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
                  : results.isEmpty
                  ? const Center(
                child: Text(
                  "No matching results found",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
                  : ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return _searchResultTile(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResultTile({required SearchItem item}) {
    final isDriver = item.type == 'driver';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openResult(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentSoft],
                ),
              ),
              child: Icon(
                isDriver
                    ? Icons.person_outline_rounded
                    : Icons.apartment_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isDriver ? "Driver" : "Constructor",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _miniBadge extends StatelessWidget {
  final String text;

  const _miniBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _statChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _statChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            color: AppColors.textSecondary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.accentSoft,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}