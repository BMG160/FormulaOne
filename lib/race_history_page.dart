import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://10.0.2.2:8000";

class RaceHistoryPage extends StatefulWidget {
  const RaceHistoryPage({super.key});

  @override
  State<RaceHistoryPage> createState() => _RaceHistoryPageState();
}

class _RaceHistoryPageState extends State<RaceHistoryPage> {
  List<dynamic> raceResults = [];
  bool isLoading = true;

  final TextEditingController yearController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController constructorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRaceResults();
  }

  Future<void> fetchRaceResults() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = "$baseUrl/race-results-history?limit=100";

      if (yearController.text.trim().isNotEmpty) {
        url += "&year=${yearController.text.trim()}";
      }

      if (driverController.text.trim().isNotEmpty) {
        url += "&driver=${driverController.text.trim()}";
      }

      if (constructorController.text.trim().isNotEmpty) {
        url += "&constructor=${constructorController.text.trim()}";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          raceResults = data["results"];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load race results");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void clearFilters() {
    yearController.clear();
    driverController.clear();
    constructorController.clear();
    fetchRaceResults();
  }

  Color getPositionColor(int? position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey;
    if (position == 3) return Colors.brown;
    return Colors.redAccent;
  }

  Widget buildFilterBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Column(
        children: [
          TextField(
            controller: yearController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration("Season / Year", "Example: 2023"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: driverController,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration("Driver", "Example: Verstappen"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: constructorController,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration("Constructor", "Example: Ferrari"),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: fetchRaceResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE10600),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: clearFilters,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE10600)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: Color(0xFFE10600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1A223A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3557)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE10600)),
      ),
    );
  }

  Widget buildRaceCard(dynamic result) {
    final int? finalPosition = result["final_position"];
    final Color badgeColor = getPositionColor(finalPosition);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3557)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: badgeColor,
            radius: 24,
            child: Text(
              finalPosition != null ? "$finalPosition" : "-",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${result["year"]} ${result["race_name"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Round ${result["round"]}",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 10),
                infoRow("Driver", result["driver_name"]),
                infoRow("Constructor", result["constructor_name"]),
                infoRow("Grid", result["grid"].toString()),
                infoRow("Points", result["points"].toString()),
                infoRow("Status", result["status"]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10600),
        elevation: 0,
        title: const Text(
          "Race Result History",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildFilterBox(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE10600),
                ),
              )
                  : raceResults.isEmpty
                  ? const Center(
                child: Text(
                  "No race results found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                itemCount: raceResults.length,
                itemBuilder: (context, index) {
                  return buildRaceCard(raceResults[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}