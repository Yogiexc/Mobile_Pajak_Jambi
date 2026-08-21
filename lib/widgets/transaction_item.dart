import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/tax_model.dart';

class TransactionItem extends StatelessWidget {
  final TaxTransaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  Color _statusColor() {
    switch (transaction.status) {
      case PaymentStatus.lunas:
        return AppColors.success;
      case PaymentStatus.belumBayar:
        return AppColors.danger;
      case PaymentStatus.pending:
        return AppColors.warning;
    }
  }

  Color _statusBgColor() {
    switch (transaction.status) {
      case PaymentStatus.lunas:
        return AppColors.successLight;
      case PaymentStatus.belumBayar:
        return AppColors.dangerLight;
      case PaymentStatus.pending:
        return AppColors.warningLight;
    }
  }

  String _statusText() {
    switch (transaction.status) {
      case PaymentStatus.lunas:
        return 'Lunas';
      case PaymentStatus.belumBayar:
        return 'Belum Bayar';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  IconData _categoryIcon() {
    switch (transaction.category) {
      case 'PKB':
        return Icons.directions_car_rounded;
      case 'PBB':
        return Icons.home_rounded;
      case 'BPHTB':
        return Icons.description_rounded;
      case 'Restoran':
        return Icons.restaurant_rounded;
      case 'Hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _categoryColor() {
    switch (transaction.category) {
      case 'PKB':
        return const Color(0xFF3B82F6);
      case 'PBB':
        return const Color(0xFF10B981);
      case 'BPHTB':
        return const Color(0xFFF59E0B);
      case 'Restoran':
        return const Color(0xFFEF4444);
      case 'Hotel':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _categoryIcon(),
                color: _categoryColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(transaction.date),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Amount + Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(transaction.amount),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBgColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
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
}
