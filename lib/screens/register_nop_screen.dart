import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';
import '../utils/responsive.dart';

class RegisterNopScreen extends StatefulWidget {
  const RegisterNopScreen({super.key});

  @override
  State<RegisterNopScreen> createState() => _RegisterNopScreenState();
}

class _RegisterNopScreenState extends State<RegisterNopScreen> {
  late MainMenuConfig _selectedConfig;
  final _taxIdController = TextEditingController();

  final List<Map<String, String>> _addedTaxes = [];

  final List<MainMenuConfig> _registerOptions = TaxConfigManager.mainMenus
      .where((menu) => menu.title != 'BPHTB') // Exclude BPHTB because it's transactional
      .toList();

  @override
  void initState() {
    super.initState();
    _selectedConfig = _registerOptions.first;
  }

  void _handleAddTax() {
    if (_taxIdController.text.isNotEmpty) {
      // Add to provider
      context.read<TaxProvider>().addBill(_taxIdController.text, _selectedConfig.title);
      
      // Keep track locally for UI feedback
      setState(() {
        _addedTaxes.add({'type': _selectedConfig.title, 'taxId': _taxIdController.text});
        _taxIdController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedConfig.title} berhasil didaftarkan!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _finishSetup() {
    context.go('/home');
  }

  @override
  void dispose() {
    _taxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Daftarkan Pajak Anda',
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punya tagihan yang harus dibayar?',
                      style: GoogleFonts.lora(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftarkan Nomor Objek Pajak (NOP) atau Nomor Pokok Wajib Pajak Daerah (NPWPD) Anda sekarang. Sistem kami akan mendeteksi otomatis usaha Anda.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tax Type Dropdown
                    Text(
                      'Jenis Registrasi',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MainMenuConfig>(
                          value: _selectedConfig,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.primaryDark,
                          ),
                          onChanged: (MainMenuConfig? newValue) {
                            setState(() {
                              _selectedConfig = newValue!;
                              _taxIdController.clear();
                            });
                          },
                          items: _registerOptions.map<DropdownMenuItem<MainMenuConfig>>((MainMenuConfig config) {
                            return DropdownMenuItem<MainMenuConfig>(
                              value: config,
                              child: Text(config.title),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Dynamic Tax ID Input
                    Text(
                      _selectedConfig.inputLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _taxIdController,
                      keyboardType: _selectedConfig.keyboardType,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: _selectedConfig.hintText,
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
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _handleAddTax,
                        icon: const Icon(Icons.add, color: AppColors.primaryDark),
                        label: Text(
                          'Daftarkan Sekarang',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Added Taxes Preview
                    if (_addedTaxes.isNotEmpty) ...[
                      Text(
                        'Pajak terdaftar (${_addedTaxes.length}):',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _addedTaxes.length,
                        itemBuilder: (context, index) {
                          final item = _addedTaxes[index];
                          final config = TaxConfigManager.getMainMenu(item['type']!);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgBlueLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(config.icon, color: config.color, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['type']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      Text(
                                        '${config.inputLabel.split('(').first.trim()}: ${item['taxId']!}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
            Container(
              padding: EdgeInsets.all(context.pagePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _finishSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Selesai & Masuk Beranda',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_addedTaxes.isEmpty) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finishSetup,
                      child: Text(
                        'Lewati, saya akan tambah nanti',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
