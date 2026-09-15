import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';

class OtherTaxesScreen extends StatelessWidget {
  const OtherTaxesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final npwpd = taxProvider.npwpd ?? '';

    // List of other taxes as requested
    final List<TaxConfig> otherTaxes = [
      const TaxConfig(title: 'PBJT Hotel', inputLabel: 'NPWPD', icon: Icons.hotel, color: Colors.indigo),
      const TaxConfig(title: 'PBJT Makanan & Minuman', inputLabel: 'NPWPD', icon: Icons.restaurant, color: Colors.orange),
      const TaxConfig(title: 'PBJT Parkir', inputLabel: 'NPWPD', icon: Icons.local_parking, color: Colors.teal),
      const TaxConfig(title: 'PBJT Hiburan', inputLabel: 'NPWPD', icon: Icons.music_note, color: Colors.pinkAccent),
      const TaxConfig(title: 'PBJT Listrik', inputLabel: 'NPWPD', icon: Icons.bolt, color: Colors.amber),
      const TaxConfig(title: 'Pajak Reklame', inputLabel: 'NPWPD', icon: Icons.campaign, color: Colors.red),
      const TaxConfig(title: 'Pajak Air Tanah', inputLabel: 'NPWPD', icon: Icons.water_drop, color: Colors.lightBlue),
      const TaxConfig(title: 'Pajak Mineral', inputLabel: 'NPWPD', icon: Icons.landscape, color: Colors.brown),
      const TaxConfig(title: 'Pajak Sarang Burung Walet', inputLabel: 'NPWPD', icon: Icons.eco, color: Colors.green),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pajak Lainnya',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Data NPWPD Anda',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'NPWPD: $npwpd',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => taxProvider.refreshDashboard(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: otherTaxes.length,
                  itemBuilder: (context, index) {
                    final tax = otherTaxes[index];
                    
                    final npwpdData = taxProvider.npwpdData;
                    final taxBills = npwpdData?.bills.where((b) {
                      final api = b.taxComponentLabel.toLowerCase().replaceAll('pajak ', '').replaceAll('pbjt ', '').replaceAll(' ', '');
                      final title = tax.title.toLowerCase().replaceAll('pajak ', '').replaceAll('pbjt ', '').replaceAll(' ', '');
                      if (api == title) return true;
                      if (title.contains('makanan') && (api.contains('restoran') || api.contains('makanan'))) return true;
                      if (title.contains('listrik') && (api.contains('penerangan') || api.contains('listrik'))) return true;
                      if (title.contains('mineral') && (api.contains('mineral') || api.contains('logam'))) return true;
                      if (title.contains('hiburan') && api.contains('hiburan')) return true;
                      if (title.contains('hotel') && api.contains('hotel')) return true;
                      if (title.contains('parkir') && api.contains('parkir')) return true;
                      if (title.contains('reklame') && api.contains('reklame')) return true;
                      if (title.contains('airtanah') && (api.contains('airtanah') || api.contains('air'))) return true;
                      if (title.contains('walet') && (api.contains('walet') || api.contains('burung'))) return true;
                      return false;
                    }).toList() ?? [];
                    final unpaidBills = taxBills.where((b) => !b.isPaid).toList();
                    final hasBills = taxBills.isNotEmpty;
                    final hasUnpaid = unpaidBills.isNotEmpty;
                    
                    String statusText = 'Tidak Ada Tagihan';
                    Color statusColor = AppColors.textHint;
                    
                    if (hasBills) {
                      if (hasUnpaid) {
                        statusText = '${unpaidBills.length} Belum Dibayar';
                        statusColor = AppColors.warning;
                      } else {
                        statusText = 'Semua Lunas';
                        statusColor = AppColors.success;
                      }
                    }
                    
                    final isClickable = hasBills;
                    
                    return InkWell(
                      onTap: isClickable ? () {
                        context.push('/npwpd-detail', extra: tax.title);
                      } : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isClickable ? Colors.white : Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isClickable ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: tax.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(tax.icon, color: tax.color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tax.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isClickable ? AppColors.primaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    statusText,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isClickable)
                              const Icon(Icons.chevron_right, color: AppColors.textHint),
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
      ),
      ),
    );
  }
}
