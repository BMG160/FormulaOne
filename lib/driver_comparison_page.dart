import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

const String baseUrl = "http://10.0.2.2:8000";

class DriverComparisonPage extends StatefulWidget {
  const DriverComparisonPage({super.key});

  @override
  State<DriverComparisonPage> createState() => _DriverComparisonPageState();
}

class _DriverComparisonPageState extends State<DriverComparisonPage> {
  List<dynamic> drivers = [];

  int? selectedDriver1;
  int? selectedDriver2;

  Map<String, dynamic>? comparisonData;

  bool isLoadingDrivers = true;
  bool isLoadingComparison = false;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/drivers"));

      if (response.statusCode == 200) {
        setState(() {
          drivers = jsonDecode(response.body);
          isLoadingDrivers = false;
        });
      } else {
        throw Exception("Failed to load drivers");
      }
    } catch (e) {
      setState(() {
        isLoadingDrivers = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading drivers: $e")),
      );
    }
  }

  Future<void> compareDrivers() async {
    if (selectedDriver1 == null || selectedDriver2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select two drivers")),
      );
      return;
    }

    if (selectedDriver1 == selectedDriver2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select two different drivers")),
      );
      return;
    }

    setState(() {
      isLoadingComparison = true;
      comparisonData = null;
    });

    try {
      final url =
          "$baseUrl/compare-drivers?driver1_id=$selectedDriver1&driver2_id=$selectedDriver2";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          comparisonData = jsonDecode(response.body);
          isLoadingComparison = false;
        });
      } else {
        throw Exception("Failed to compare drivers");
      }
    } catch (e) {
      setState(() {
        isLoadingComparison = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error comparing drivers: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10600),
        title: const Text(
          "Driver Comparison",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoadingDrivers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSelectionCard(),
            const SizedBox(height: 20),

            if (isLoadingComparison)
              const Center(child: CircularProgressIndicator()),

            if (comparisonData != null) buildComparisonContent(),
          ],
        ),
      ),
    );
  }

  Widget buildSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Two Drivers",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          buildDriverDropdown(
            label: "First Driver",
            value: selectedDriver1,
            onChanged: (value) {
              setState(() {
                selectedDriver1 = value;
              });
            },
          ),

          const SizedBox(height: 12),

          buildDriverDropdown(
            label: "Second Driver",
            value: selectedDriver2,
            onChanged: (value) {
              setState(() {
                selectedDriver2 = value;
              });
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: compareDrivers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Compare Drivers",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildDriverDropdown({
    required String label,
    required int? value,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF1A223A),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A223A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3557)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      items: drivers.map((driver) {
        final int driverId = driver["driverId"];
        final String driverName = driver["driverName"] ?? "Unknown";
        final String driverRef = driver["driverRef"] ?? "";

        return DropdownMenuItem<int>(
          value: driverId,
          child: Text("$driverName ($driverRef)"),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildComparisonContent() {
    final driver1 = comparisonData!["driver1"];
    final driver2 = comparisonData!["driver2"];

    return Column(
      children: [
        buildHeaderComparison(driver1, driver2),
        const SizedBox(height: 20),

        buildStatsGrid(driver1, driver2),
        const SizedBox(height: 20),

        buildSeasonPointsChart(driver1, driver2),
        const SizedBox(height: 20),

        buildConstructorHistory(driver1, driver2),
      ],
    );
  }

  Widget buildHeaderComparison(dynamic driver1, dynamic driver2) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE10600),
            Color(0xFF8B0000),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: buildDriverHeader(driver1),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "VS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: buildDriverHeader(driver2),
          ),
        ],
      ),
    );
  }

  Widget buildDriverHeader(dynamic driver) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Text(
            driver["driverRef"].toString().substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFE10600),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          driver["driverName"],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildStatsGrid(dynamic driver1, dynamic driver2) {
    return Column(
      children: [
        buildStatRow(
          "Total Points",
          driver1["totalPoints"].toString(),
          driver2["totalPoints"].toString(),
        ),
        buildStatRow(
          "Total Races",
          driver1["totalRaces"].toString(),
          driver2["totalRaces"].toString(),
        ),
        buildStatRow(
          "Wins",
          driver1["wins"].toString(),
          driver2["wins"].toString(),
        ),
        buildStatRow(
          "Podiums",
          driver1["podiums"].toString(),
          driver2["podiums"].toString(),
        ),
        buildStatRow(
          "Average Finish",
          driver1["averageFinish"].toString(),
          driver2["averageFinish"].toString(),
        ),
        buildStatRow(
          "Best Finish",
          driver1["bestFinish"].toString(),
          driver2["bestFinish"].toString(),
        ),
      ],
    );
  }

  Widget buildStatRow(String title, String value1, String value2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value1,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSeasonPointsChart(dynamic driver1, dynamic driver2) {
    final List<dynamic> d1Points = driver1["seasonPoints"];
    final List<dynamic> d2Points = driver2["seasonPoints"];

    final List<FlSpot> d1Spots = d1Points.map((item) {
      return FlSpot(
        item["year"].toDouble(),
        item["points"].toDouble(),
      );
    }).toList();

    final List<FlSpot> d2Spots = d2Points.map((item) {
      return FlSpot(
        item["year"].toDouble(),
        item["points"].toDouble(),
      );
    }).toList();

    return Container(
      height: 330,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Season Points Comparison",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              buildLegendBox(Colors.red, driver1["driverRef"]),
              const SizedBox(width: 16),
              buildLegendBox(Colors.blue, driver2["driverRef"]),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: const Color(0xFF131A2E),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF2A3557)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: d1Spots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: d2Spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget buildConstructorHistory(dynamic driver1, dynamic driver2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Constructor History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          buildConstructorBlock(driver1),
          const SizedBox(height: 16),
          buildConstructorBlock(driver2),
        ],
      ),
    );
  }

  Widget buildConstructorBlock(dynamic driver) {
    final constructors = driver["constructors"] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          driver["driverName"],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: constructors.map((constructor) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A223A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                constructor.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}