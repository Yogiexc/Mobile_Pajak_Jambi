import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';

class SelectPbjtScreen extends StatefulWidget {
  final String npwpd;
  
  const SelectPbjtScreen({super.key, required this.npwpd});

  @override
  State<SelectPbjtScreen> createState() => _SelectPbjtScreenState();
}

class _SelectPbjtScreenState extends State<SelectPbjtScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateFetchData();
  }

  Future<void> _simulateFetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSubjenis(String subjenis) async {
    try {
      await context.read<TaxProvider>().addNpwpd(widget.npwpd);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NPWPD didaftarkan. Tagihan $subjenis akan muncul jika ada di Bapenda.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simulasi data dari backend: NPWPD ini punya Makanan & Minuman dan Perhotelan
    final List<Map<String, dynamic>> activeTaxes = [
      {'title': 'PBJT Makanan & Minuman', 'status': 'Ada Tagihan', 'color': Colors.red},
      {'title': 'PBJT Perhotelan', 'status': 'Lunas', 'color': AppColors.success},
      {'title': 'Pajak Reklame', 'status': 'Ada Tagihan', 'color': Colors.red},
      {'title': 'Pajak Air Tanah', 'status': 'Tidak Ada Data', 'color': Colors.grey},
      {'title': 'PBJT Parkir', 'status': 'Tidak Ada Data', 'color': Colors.grey},
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
          'Pilih Jenis Usaha',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Usaha Ditemukan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NPWPD: ${widget.npwpd}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pilih jenis pajak untuk melihat atau membayar tagihan:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: activeTaxes.length,
                    itemBuilder: (context, index) {
                      final item = activeTaxes[index];
                      final config = TaxConfigManager.getDetailConfig(item['title']);
                      final isClickable = item['status'] == 'Ada Tagihan';

                      return InkWell(
                        onTap: isClickable ? () => _selectSubjenis(item['title']) : null,
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
                                  color: config.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(config.icon, color: config.color, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isClickable ? AppColors.primaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['status'],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: item['color'],
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
