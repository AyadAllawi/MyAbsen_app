import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/history.dart';
import 'package:myabsen_project/model/history.dart';

class HistoryAbsenPage extends StatefulWidget {
  const HistoryAbsenPage({super.key});

  @override
  State<HistoryAbsenPage> createState() => _HistoryAbsenPageState();
}

class _HistoryAbsenPageState extends State<HistoryAbsenPage> {
  late Future<GetHistoryModel> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = HistoryService.getHistory();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(date);
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "masuk":
        return Colors.green;
      case "izin":
        return Colors.orange;
      case "alpha":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Absensi",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A5CF6),
      ),
      body: FutureBuilder<GetHistoryModel>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return const Center(child: Text("Belum ada riwayat absensi"));
          }

          final historyList = snapshot.data!.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row Tanggal + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(item.attendanceDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(item.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status?.toUpperCase() ?? "-",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Check In
                      Row(
                        children: [
                          const Icon(
                            Icons.login,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Masuk: ${item.checkInTime ?? '-'} (${item.checkInAddress ?? '-'})",
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                          ),
                        ],
                      ),

                      // Check Out
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 18, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Pulang: ${item.checkOutTime ?? 'Belum Absen'} (${item.checkOutAddress ?? '-'})",
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                          ),
                        ],
                      ),

                      // Alasan Izin
                      if (item.status == "izin" &&
                          item.alasanIzin != null &&
                          item.alasanIzin!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Alasan: ${item.alasanIzin}",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
