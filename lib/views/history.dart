import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/history.dart'; // Pastikan ini import ke file API-mu
import 'package:myabsen_project/model/history.dart';
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
    setState(() => isLoading = true);
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

  // =======================================================================
  // =================== PENAMBAHAN FUNGSI DELETE ==========================
  // =======================================================================

  Future<void> _handleDeleteAbsen(int idAbsen) async {
    // <-- KUNCI PERBAIKAN: PASTIKAN INI 'int'
    try {
      await HistoryService.deleteAbsen(idAbsen: idAbsen);
      setState(() {
        historyData.removeWhere((item) => item.id == idAbsen);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data absen berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('⛔️ TERTANGKAP ERROR SAAT MENGHAPUS!');
      print('TIPE ERROR: ${e.runtimeType}'); // Mencetak tipe errornya
      print('PESAN ERROR: $e'); // Mencetak pesan errornya
      print(
        'JEJAK STACK (LOKASI ERRORR): $stackTrace',
      ); // Mencetak jejak errornya

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Kita tampilkan juga tipe errornya di notifikasi
            content: Text("Gagal: [${e.runtimeType}] ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(int idAbsen) {
    // <-- KUNCI PERBAIKAN: PASTIKAN INI 'int'
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text(
            "Yakin mau hapus data absen ini? Tindakan ini tidak bisa dibatalkan.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Ya, Hapus",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteAbsen(idAbsen);
              },
            ),
          ],
        );
      },
    );
  }
  // =======================================================================
  // =================== AKHIR DARI PENAMBAHAN FUNGSI ======================
  // =======================================================================

  Future<void> _createAndExportPdf() async {
    // Kode PDF lu yang sudah ada (tidak diubah)
    var status = await Permission.manageExternalStorage.request();

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin penyimpanan ditolak.")),
        );
      }
      return;
    }

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

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final file = File('${downloadsDir.path}/riwayat_absen.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF berhasil disimpan di: ${file.path}")),
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

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("EEEE, dd MMMM yy", "id_ID").format(date);
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
                            // dibungkus ListView biar bisa ditarik (refresh)
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
                              // =================================================================
                              // ================= MODIFIKASI BAGIAN CARD ========================
                              // =================================================================
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    15,
                                    8,
                                    8,
                                    8,
                                  ),
                                  title: Row(
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
                                          color: getStatusColor(item.status),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                            // <-- TAMBAHKAN INI
                                            child: Text(
                                              "Masuk: ${item.checkInTime ?? '-'} ",
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

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
                                              "Pulang: ${item.checkOutTime ?? 'Belum Absen'}",
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () {
                                      if (item.id != null) {
                                        _showDeleteConfirmationDialog(item.id!);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          Center(
            child: Text(
              "© 2025 Ayad Allawi",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
