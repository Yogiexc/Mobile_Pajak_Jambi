import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';
import 'package:go_router/go_router.dart';

class TaxDetailScreen extends StatelessWidget {
  const TaxDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Collect all registered tax objects
    final List<String> allObjects = [...taxProvider.nops];
    if (taxProvider.hasNpwpd) {
      allObjects.add(taxProvider.npwpd!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFC4E0F4), // match home screen light blue
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: -20,
            child: Image.asset(
              'assets/images/illustration.png',
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                        ),
                      ),
                      Text(
                        'Detail Pajak Anda',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // Optimasi loading
                        // We might need to refresh just Nops and npwpd
                        await taxProvider.refreshDashboard();
                      },
                      child: allObjects.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: allObjects.length,
                              itemBuilder: (context, index) {
                                final objectId = allObjects[index];
                                final isNpwpd = objectId == taxProvider.npwpd;
                                
                                // Find bills for this object
                                final bills = taxProvider.pendingBills
                                    .where((b) => b.taxId == objectId)
                                    .toList();
                                
                                return _buildTaxObjectCard(
                                  context: context,
                                  objectId: objectId,
                                  isNpwpd: isNpwpd,
                                  bills: bills,
                                  formatter: currencyFormatter,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Belum ada objek pajak.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxObjectCard({
    required BuildContext context,
    required String objectId,
    required bool isNpwpd,
    required List<TaxBill> bills,
    required NumberFormat formatter,
  }) {
    final title = isNpwpd ? 'NPWPD' : 'NOP';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              objectId,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${bills.length} tagihan belum dibayar',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.danger,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          if (bills.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Semua tagihan untuk objek ini sudah lunas.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...bills.map((bill) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bill.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bill.status,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Periode', bill.taxPeriod),
                    _buildDetailRow('Jatuh Tempo', DateFormat('dd MMM yyyy', 'id_ID').format(bill.dueDate)),
                    _buildDetailRow('Pokok', formatter.format(bill.amount)),
                    if (bill.denda > 0) _buildDetailRow('Denda', formatter.format(bill.denda)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          formatter.format(bill.total),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
