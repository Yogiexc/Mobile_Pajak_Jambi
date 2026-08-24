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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pajak Lainnya',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
              child: ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: otherTaxes.length,
                itemBuilder: (context, index) {
                  final tax = otherTaxes[index];
                  
                  // Check status
                  final pendingBill = taxProvider.pendingBills.cast<TaxBill?>().firstWhere(
                    (b) => b!.title == tax.title && b.taxId == npwpd,
                    orElse: () => null,
                  );
                  
                  final historyTx = taxProvider.history.cast<TaxTransaction?>().firstWhere(
                    (t) => t!.title == tax.title && t.taxId == npwpd && t.isSuccess,
                    orElse: () => null,
                  );
                  
                  String status = 'Tidak Ada Data';
                  Color statusColor = Colors.grey;
                  if (pendingBill != null) {
                    status = 'Ada Tagihan';
                    statusColor = Colors.red;
                  } else if (historyTx != null) {
                    status = 'Lunas';
                    statusColor = AppColors.success;
                  }
                  
                  final isClickable = pendingBill != null;

                  return InkWell(
                    onTap: isClickable ? () {
                      // Navigate directly to detail/payment for this bill
                      context.push('/detail', extra: pendingBill.id);
                    } : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isClickable ? Colors.white : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isClickable ? AppColors.primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
                        ),
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
                                  status,
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
          ],
        ),
      ),
    );
  }
}
