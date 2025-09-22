import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/history.dart';
import 'package:myabsen_project/model/history.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class HistoryAbsenPage extends StatefulWidget {
  const HistoryAbsenPage({super.key});

  @override
  State<HistoryAbsenPage> createState() => _HistoryAbsenPageState();
}

class _HistoryAbsenPageState extends State<HistoryAbsenPage> {
  bool isLoading = true;
  List<Datum> historyData = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    setState(
      () => isLoading = true,
    ); // tambahin ini biar muncul loading saat refresh
    try {
      final response = await HistoryService.getHistory();
      setState(() {
        historyData = response.data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat riwayat: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _createAndExportPdf() async {
    final status = await Permission.storage.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin penyimpanan ditolak.")),
        );
      }
      return;
    }
    if (status.isGranted) {
      try {
        final pdf = pw.Document();
        final headers = ['Tanggal', 'Check-in', 'Check-out'];

        final data = historyData.map((history) {
          return [
            formatDate(history.attendanceDate),
            history.checkInTime ?? '-',
            history.checkOutTime ?? '-',
          ];
        }).toList();

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Riwayat Absensi',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table.fromTextArray(
                    headers: headers,
                    data: data,
                    cellAlignment: pw.Alignment.centerLeft,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    border: pw.TableBorder.all(color: PdfColors.black),
                  ),
                ],
              );
            },
          ),
        );
        final downloadsPath = await getApplicationDocumentsDirectory();
        final file = File('${downloadsPath.path}/riwayat_absen.pdf');

        await file.writeAsBytes(await pdf.save());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "PDF berhasil disimpan di folder: ${downloadsPath.path}",
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal menyimpan file: $e")));
        }
      }
    }
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
      backgroundColor: const Color(0xFFE6E7EE),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6E8BFA),
                  Color(0xFF5271FF),
                  Color(0xFF436EFF),
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Riwayat Absensi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    onPressed: _createAndExportPdf,
                  ),
                ],
              ),
            ),
          ),
          // BODY
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchHistoryData,
                    child: historyData.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 50),
                              Center(child: Text("Belum ada riwayat absensi")),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: historyData.length,
                            itemBuilder: (context, index) {
                              final item = historyData[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                              color: getStatusColor(
                                                item.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.logout,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "Pulang: ${item.checkOutTime ?? 'Belum Absen'} (${item.checkOutAddress ?? '-'})",
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.status == "izin" &&
                                          item.alasanIzin != null &&
                                          item.alasanIzin!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
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
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
