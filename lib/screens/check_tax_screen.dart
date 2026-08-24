import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';

class CheckTaxScreen extends StatefulWidget {
  final String serviceName;
  
  const CheckTaxScreen({super.key, required this.serviceName});

  @override
  State<CheckTaxScreen> createState() => _CheckTaxScreenState();
}

class _CheckTaxScreenState extends State<CheckTaxScreen> {
  final _taxIdController = TextEditingController();
  late TaxConfig _config;

  @override
  void initState() {
    super.initState();
    // Use getDetailConfig instead of getMainMenu to support sub-taxes
    _config = TaxConfigManager.getDetailConfig(widget.serviceName);
  }

  void _checkTax() {
    if (_taxIdController.text.isNotEmpty) {
      if (widget.serviceName == 'Pajak Lainnya') {
        context.read<TaxProvider>().addNpwpd(_taxIdController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NPWPD berhasil didaftarkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pushReplacement('/other-taxes');
      } else if (widget.serviceName == 'Pajak PBB') {
        context.read<TaxProvider>().addNop(_taxIdController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NOP berhasil didaftarkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Go back to PBB List
      } else {
        // For BPHTB and specific PBJT types
        context.read<TaxProvider>().addBill(_taxIdController.text, widget.serviceName);
        
        // Get the newly added bill's ID
        final newBill = context.read<TaxProvider>().pendingBills.last;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencarian berhasil. Tagihan ditemukan!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Go straight to detail page instead of home
        context.pushReplacement('/detail', extra: newBill.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Cek Tagihan ${_config.title}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan ${_config.inputLabel}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _taxIdController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: widget.serviceName == 'Pajak PBB' ? 'Contoh: 15.71.010.001.001-0123.0' : (widget.serviceName == 'BPHTB' ? 'Contoh: TR-2026-00123' : 'Contoh: P.001234567890'),
                  hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.bgWhite,
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
                  prefixIcon: Icon(_config.icon, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _checkTax,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cek & Tambahkan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
