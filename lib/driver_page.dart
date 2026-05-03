import 'package:flutter/material.dart';
import 'package:xgboostranker_app/cloud_fire_store_impl.dart';
import 'package:xgboostranker_app/driver_vo.dart';

class DriverPage extends StatelessWidget {
  final String id;

  const DriverPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B2D),
      body: FutureBuilder<DriverVO?>(
        future: CloudFireStoreImpl().getDriver(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                "Driver not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final driver = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF081530),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0B1736),
                          Color(0xFF12264A),
                          Color(0xFF1C3356),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.white.withOpacity(0.14),
                              child: Text(
                                _getInitials(driver.fullName ?? "Unknown"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              driver.fullName ?? "Unknown",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _topChip(
                                  icon: Icons.flag_outlined,
                                  label: driver.nationality ?? "Unknown",
                                ),
                                _topChip(
                                  icon: Icons.code,
                                  label: (driver.code != null &&
                                      driver.code!.trim().isNotEmpty)
                                      ? driver.code
                                      : "UNK",
                                ),
                                _topChip(
                                  icon: Icons.sports_motorsports_outlined,
                                  label: driver.number != null
                                      ? "#${driver.number}"
                                      : "No Number",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                  child: Column(
                    children: [
                      _buildMainInfoCard(driver),
                      const SizedBox(height: 18),
                      _buildAdditionalInfoCard(driver),
                      const SizedBox(height: 18),
                      _buildReferenceCard(driver),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainInfoCard(DriverVO driver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A3A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF243B6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driver Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          _infoTile(Icons.badge_outlined, 'Full Name', driver.fullName ?? "Unknown"),
          const SizedBox(height: 14),
          _infoTile(Icons.code_outlined, 'Code', driver.code ?? "UNK"),
          const SizedBox(height: 14),
          _infoTile(Icons.cake_outlined, 'Date of Birth', driver.dob ?? "Unknown"),
          const SizedBox(height: 14),
          _infoTile(Icons.public_outlined, 'Nationality', driver.nationality ?? "Unknown"),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(DriverVO driver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A3A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF243B6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Info',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          _infoTile(Icons.person_outline, 'Forename', driver.forename ?? 'N/A'),
          const SizedBox(height: 14),
          _infoTile(Icons.person_2_outlined, 'Surname', driver.surname ?? 'N/A'),
          const SizedBox(height: 14),
          _infoTile(Icons.tag_outlined, 'Driver Ref', driver.driverRef ?? "Unknown"),
          const SizedBox(height: 14),
          _infoTile(
            Icons.onetwothree_outlined,
            'Car Number',
            driver.number != null ? driver.number.toString() : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(DriverVO driver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111F45),
            Color(0xFF0D1734),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF243B6B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFF5A5A),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.link, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reference',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  driver.url ?? 'No reference URL available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB8C1D9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF142347),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF243B6B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA8B3CF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _topChip({required IconData icon, required String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            label ?? "Unknown",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}