import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';
import '../widgets/tax_preview_dialog.dart';

class CheckTaxScreen extends StatefulWidget {
  final String serviceName;
  
  const CheckTaxScreen({super.key, required this.serviceName});

  @override
  State<CheckTaxScreen> createState() => _CheckTaxScreenState();
}

class _CheckTaxScreenState extends State<CheckTaxScreen> {
  final _taxIdController = TextEditingController();
  late TaxConfig _config;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use getDetailConfig instead of getMainMenu to support sub-taxes
    _config = TaxConfigManager.getDetailConfig(widget.serviceName);
  }

  Future<void> _checkTax() async {
    if (_taxIdController.text.isEmpty || _isLoading) return;
    final taxId = _taxIdController.text.trim();
    final provider = context.read<TaxProvider>();

    setState(() => _isLoading = true);
    try {
      if (widget.serviceName == 'Pajak Lainnya') {
        final preview = await provider.checkNpwpd(taxId);
        if (!mounted) return;
        setState(() => _isLoading = false);
        final confirmed = await showTaxObjectConfirmDialog(
          context: context,
          title: 'Konfirmasi NPWPD',
          rows: {
            'NPWPD': preview['npwpd_number']?.toString() ?? taxId,
            'Nama Usaha': preview['business_name']?.toString() ?? '-',
            'Jenis Usaha': preview['business_type']?.toString() ?? '-',
            'Pemilik': preview['owner_name']?.toString() ?? '-',
          },
        );
        if (!confirmed || !mounted) return;
        setState(() => _isLoading = true);
        await provider.addNpwpd(taxId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NPWPD berhasil didaftarkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pushReplacement('/other-taxes');
      } else if (widget.serviceName == 'Pajak PBB') {
        final preview = await provider.checkNop(taxId);
        if (!mounted) return;
        setState(() => _isLoading = false);
        final confirmed = await showTaxObjectConfirmDialog(
          context: context,
          title: 'Konfirmasi NOP',
          rows: {
            'NOP': preview['nop_number']?.toString() ?? taxId,
            'Objek Pajak': preview['object_name']?.toString() ?? '-',
            'Pemilik': preview['owner_name']?.toString() ?? '-',
            'Alamat': preview['object_address']?.toString() ?? '-',
          },
        );
        if (!confirmed || !mounted) return;
        setState(() => _isLoading = true);
        await provider.addNop(taxId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NOP berhasil didaftarkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        await provider.addBill(taxId, widget.serviceName);
        if (!mounted) return;
        final newBill = context.read<TaxProvider>().pendingBills.last;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencarian berhasil. Tagihan ditemukan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pushReplacement('/detail', extra: newBill.id);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cek ${_config.title}',
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
                  onPressed: _isLoading ? null : _checkTax,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Mencari Data...' : 'Cek & Tambahkan',
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
