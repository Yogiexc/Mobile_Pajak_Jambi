import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';
import '../api/api_config.dart';
import '../api/api_client.dart';

class ReceiptScreen extends StatefulWidget {
  final String transactionId;

  const ReceiptScreen({super.key, required this.transactionId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    TaxTransaction? transaction;
    for (final item in taxProvider.history) {
      if (item.id == widget.transactionId) {
        transaction = item;
        break;
      }
    }
    transaction ??= taxProvider.lastTransaction;

    if (transaction == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Transaksi tidak ditemukan')),
      );
    }
    
    final tx = transaction;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Bukti Pembayaran',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Pembayaran Berhasil',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(tx.date),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.textHint, thickness: 1),
                  ),

                  _buildDetailRow('NPWPD', taxProvider.npwpd ?? 'P.2.0004913.01.009'),
                  _buildDetailRow('Jenis Pajak', tx.title),
                  _buildDetailRow('Masa Pajak', '01/06/2026 S.D. 30/06/2026'),
                  _buildDetailRow('Kode Rekening', '4.1.1.19.04.001.00.00'),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Pajak yang Dibayar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDetailRow('Tanggal Pembayaran', dateFormat.format(tx.date)),
                  _buildDetailRow('Penerima Pembayaran', tx.bankName.toUpperCase()),
                  _buildDetailRow('Referensi Bank', tx.id.replaceAll('-', '')),
                  _buildDetailRow('Pembayaran Pajak', currencyFormatter.format(tx.amount)),
                  _buildDetailRow('Sanksi/Bunga', currencyFormatter.format(tx.denda)),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.textHint),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(tx.amount + tx.denda),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDownloading ? null : () async {
                      setState(() => _isDownloading = true);
                      try {
                        final url = Uri.parse('${ApiConfig.baseUrl}/transactions/${tx.id}/proof');
                        final response = await http.get(url, headers: {
                          'Authorization': 'Bearer ${ApiClient.instance.token}',
                          'Accept': 'application/pdf',
                        });
                        
                        if (response.statusCode == 200) {
                          final dir = await getApplicationDocumentsDirectory();
                          final file = File('${dir.path}/Bukti_Pembayaran_${tx.id}.pdf');
                          await file.writeAsBytes(response.bodyBytes);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Berhasil diunduh! Membuka file...')),
                            );
                          }
                          await OpenFile.open(file.path);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal mengunduh bukti pembayaran (Status: ${response.statusCode})')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Terjadi kesalahan: $e')),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => _isDownloading = false);
                        }
                      }
                    },
                    icon: _isDownloading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_rounded),
                    label: Text(_isDownloading ? 'Mengunduh...' : 'Unduh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final downloadUrl = '${ApiConfig.baseUrl}/transactions/${tx.id}/proof';
                      final text = 'Bukti Pembayaran Pajak\nNo: ${tx.id}\nTanggal: ${dateFormat.format(tx.date)}\nTotal: ${currencyFormatter.format(tx.amount + tx.denda)}\nUnduh: $downloadUrl';
                      await Share.share(text);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
