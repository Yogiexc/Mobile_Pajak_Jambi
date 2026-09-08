import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tax_provider.dart';
import '../constants/colors.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePin() async {
    if (_currentPinController.text.isEmpty || 
        _newPinController.text.isEmpty || 
        _confirmPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN baru tidak cocok.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<TaxProvider>().changePin(
        _currentPinController.text,
        _newPinController.text,
        _confirmPinController.text,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil diubah!'), backgroundColor: AppColors.success),
      );
      
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool obscureText, VoidCallback onToggleVisibility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.bgWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti PIN', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'PIN Saat Ini',
                'Masukkan 6 digit PIN lama',
                _currentPinController,
                _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                'PIN Baru',
                'Masukkan 6 digit PIN baru',
                _newPinController,
                _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
              ),
              _buildTextField(
                'Konfirmasi PIN Baru',
                'Ulangi 6 digit PIN baru',
                _confirmPinController,
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Simpan PIN', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
