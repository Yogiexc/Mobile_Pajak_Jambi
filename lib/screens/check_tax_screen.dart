import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';
import '../utils/responsive.dart';

class CheckTaxScreen extends StatefulWidget {
  final String serviceName;
  
  const CheckTaxScreen({super.key, required this.serviceName});

  @override
  State<CheckTaxScreen> createState() => _CheckTaxScreenState();
}

class _CheckTaxScreenState extends State<CheckTaxScreen> {
  final _taxIdController = TextEditingController();
  late MainMenuConfig _config;

  @override
  void initState() {
    super.initState();
    _config = TaxConfigManager.getMainMenu(widget.serviceName);
  }

  void _checkTax() {
    if (_taxIdController.text.isNotEmpty) {
      context.read<TaxProvider>().addBill(_taxIdController.text, widget.serviceName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pencarian berhasil. Tagihan terkait ditambahkan ke Beranda!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.pop();
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
          padding: EdgeInsets.all(context.pagePadding),
          child: context.constrainContent(
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
                keyboardType: _config.keyboardType,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: _config.hintText,
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
      ),
    );
  }
}
