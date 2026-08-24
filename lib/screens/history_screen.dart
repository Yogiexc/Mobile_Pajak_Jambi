import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedTab = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Filter history based on tab and search
    List<TaxTransaction> filteredHistory = taxProvider.history;
    
    if (_selectedTab != 'Semua') {
      filteredHistory = filteredHistory.where((t) {
        if (_selectedTab == 'PBB') return t.title.contains('PBB');
        if (_selectedTab == 'BPHTB') return t.title.contains('BPHTB');
        if (_selectedTab == 'PBJT') return t.title.contains('PBJT');
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredHistory = filteredHistory.where((t) => 
        t.taxId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat',
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari NOP / NPWPD...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.bgWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab('Semua'),
                  const SizedBox(width: 8),
                  _buildTab('PBB'),
                  const SizedBox(width: 8),
                  _buildTab('PBJT'),
                  const SizedBox(width: 8),
                  _buildTab('BPHTB'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
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
