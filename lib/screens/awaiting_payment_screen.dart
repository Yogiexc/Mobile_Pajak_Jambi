import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class AwaitingPaymentScreen extends StatefulWidget {
  const AwaitingPaymentScreen({super.key});

  @override
  State<AwaitingPaymentScreen> createState() => _AwaitingPaymentScreenState();
}

class _AwaitingPaymentScreenState extends State<AwaitingPaymentScreen> {
  Timer? _pollTimer;
  bool _isChecking = false;
  bool _isSimulating = false;
  
  int _pollCount = 0;
  final int _maxPolls = 15;
  Duration _pollInterval = const Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      _pollCount++;
      _checkStatus();

      if (_pollCount >= _maxPolls) {
        _pollTimer?.cancel();
      } else if (_pollCount == 5) {
        _pollInterval = const Duration(seconds: 8);
        _startPolling();
      } else if (_pollCount == 10) {
        _pollInterval = const Duration(seconds: 15);
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool fromButton = false}) async {
    final provider = context.read<TaxProvider>();
    final tx = provider.lastTransaction;
    if (tx == null) return;

    if (fromButton) setState(() => _isChecking = true);

    try {
      final updated = await provider.fetchTransaction(tx.id);
      if (!mounted) return;

      if (updated.isSuccess) {
        _pollTimer?.cancel();
        // Refresh data di background setelah navigasi
        provider.refreshAfterPayment();
        context.go('/success');
      } else if (updated.isFailed) {
        _pollTimer?.cancel();
        if (fromButton) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran gagal atau kedaluwarsa.')),
          );
        }
      }
    } catch (e) {
      if (fromButton && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memeriksa status: $e')));
      }
    } finally {
      if (fromButton && mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _simulatePayment() async {
    final provider = context.read<TaxProvider>();
    final tx = provider.lastTransaction;
    if (tx == null) return;

    setState(() => _isSimulating = true);
    try {
      // simulatePayment sudah dapat data sukses dari backend
      // langsung update state & redirect tanpa perlu fetchTransaction lagi
      await provider.simulatePayment(tx.id);
      if (!mounted) return;
      _pollTimer?.cancel();
      // Refresh data di background, tidak blocking navigasi
      provider.refreshAfterPayment();
      context.go('/success');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mensimulasikan pembayaran: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TaxProvider>().lastTransaction;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'id_ID');
    final expiredAt = tx?.isQris == true ? tx?.qrExpiredAt : tx?.vaExpiredAt;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Menunggu Pembayaran',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Selesaikan pembayaran sesuai instruksi di bawah. Status akan diperbarui otomatis setelah bank mengonfirmasi.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            tx?.bankName ?? 'Pembayaran',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormatter.format(tx?.amount ?? 0),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (expiredAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Berlaku sampai ${dateFormat.format(expiredAt)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (tx?.isQris == true) ...[
                            if (tx?.qrImageUrl != null &&
                                tx!.qrImageUrl!.isNotEmpty)
                              Image.network(
                                tx.qrImageUrl!,
                                width: 220,
                                height: 220,
                                errorBuilder: (_, _, _) =>
                                    _qrFallback(tx.qrString),
                              )
                            else
                              _qrFallback(tx?.qrString),
                            const SizedBox(height: 12),
                            Text(
                              'Scan QRIS untuk membayar',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Nomor Virtual Account',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              tx?.vaNumber?.isNotEmpty == true
                                  ? tx!.vaNumber!
                                  : '-',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: tx?.vaNumber == null
                                  ? null
                                  : () {
                                      Clipboard.setData(
                                        ClipboardData(text: tx!.vaNumber!),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Nomor VA disalin'),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.copy, size: 16),
                              label: Text(
                                'Salin nomor VA',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isChecking
                      ? null
                      : () => _checkStatus(fromButton: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Cek Status Pembayaran',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSimulating ? null : _simulatePayment,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSimulating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '🧪 Simulasikan Pembayaran Diterima (demo)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrFallback(String? qrString) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        qrString?.isNotEmpty == true ? qrString! : 'Kode QR belum tersedia',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
