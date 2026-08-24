import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';
import '../utils/responsive.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; // 0: Semua, 1: Berhasil, 2: Gagal

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Filter history based on tab
    List<TaxTransaction> filteredHistory = taxProvider.history;
    if (_selectedTab == 1) {
      filteredHistory = filteredHistory.where((t) => t.isSuccess).toList();
    } else if (_selectedTab == 2) {
      filteredHistory = filteredHistory.where((t) => !t.isSuccess).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.pagePadding,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat',
                    style: GoogleFonts.lora(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Icon(Icons.search, color: AppColors.primaryDark),
                ],
              ),
            ),
            
            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                children: [
                  _buildTab(0, 'Semua'),
                  const SizedBox(width: 12),
                  _buildTab(1, 'Berhasil'),
                  const SizedBox(width: 12),
                  _buildTab(2, 'Gagal'),
                ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // List
            Expanded(
              child: filteredHistory.isEmpty 
                ? Center(
                    child: Text(
                      'Tidak ada riwayat',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = filteredHistory[index];
                      // Grouping logically would require grouping the list by month.
                      // For simplicity, we just list them out.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0 || filteredHistory[index].date.month != filteredHistory[index-1].date.month)
                            _buildMonthGroup(DateFormat('MMMM yyyy', 'id_ID').format(item.date).toUpperCase()),
                          _buildHistoryItem(
                            isQris: item.isQris,
                            bankName: item.bankName,
                            taxId: item.taxId,
                            date: DateFormat('dd MMM').format(item.date),
                            type: item.title,
                            amount: currencyFormatter.format(item.amount),
                            isSuccess: item.isSuccess,
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.textHint),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGroup(String month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        month,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required bool isQris,
    required String bankName,
    required String taxId,
    required String date,
    required String type,
    required String amount,
    required bool isSuccess,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(
                isQris ? Icons.qr_code_2 : Icons.account_balance,
                color: isQris ? AppColors.primaryDark : AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taxId,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $type - $bankName',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.successLight : AppColors.dangerLight).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSuccess ? 'Berhasil' : 'Gagal',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
