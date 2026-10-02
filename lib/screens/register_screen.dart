import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tax_provider.dart';
import '../constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showPinStep = false;

  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  // New PIN variables
  String _pinString = '';
  String _confirmPinString = '';
  bool _isConfirmingPin = false;

  @override
  void dispose() {
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_isConfirmingPin) {
      if (_confirmPinString.length < 6) {
        setState(() => _confirmPinString += number);
        if (_confirmPinString.length == 6) {
          if (_pinString == _confirmPinString) {
            _pinController.text = _pinString;
            _handleRegister();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN tidak cocok, silakan coba lagi.'), backgroundColor: Colors.red),
            );
            setState(() {
              _pinString = '';
              _confirmPinString = '';
              _isConfirmingPin = false;
            });
          }
        }
      }
    } else {
      if (_pinString.length < 6) {
        setState(() => _pinString += number);
        if (_pinString.length == 6) {
          setState(() => _isConfirmingPin = true);
        }
      }
    }
  }

  void _onBackspace() {
    if (_isConfirmingPin) {
      if (_confirmPinString.isNotEmpty) {
        setState(() => _confirmPinString = _confirmPinString.substring(0, _confirmPinString.length - 1));
      } else {
        setState(() => _isConfirmingPin = false);
      }
    } else {
      if (_pinString.isNotEmpty) {
        setState(() => _pinString = _pinString.substring(0, _pinString.length - 1));
      }
    }
  }

  Widget _buildKeypadButton(String number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          number,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    if (_nikController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom wajib.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_nikController.text.length != 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIK harus terdiri dari 18 digit angka.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _showPinStep = true);
  }

  Future<void> _handleRegister() async {
    if (_pinController.text.isEmpty || _pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus 6 digit angka.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<TaxProvider>().registerUser(
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _pinController.text.trim(),
        nik: _nikController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat! Memuat...'), backgroundColor: AppColors.success),
      );

      // Auto-login after successful registration
      await context.read<TaxProvider>().loginUser(
        _nikController.text.trim(), 
        _passwordController.text
      );
      
      if (mounted) {
        context.go('/register-nop');
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NIK (Nomor Induk Kependudukan)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nikController,
          keyboardType: TextInputType.number,
          maxLength: 18,
          decoration: const InputDecoration(hintText: 'Masukkan 18 digit NIK', counterText: ''),
        ),
        const SizedBox(height: 20),
        
        Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'nama@email.com'),
        ),
        const SizedBox(height: 20),

        Text('Nomor HP', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '0812-3456-7890'),
        ),
        const SizedBox(height: 20),
        
        Text('Kata Sandi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Minimal 8 karakter',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        Text('Konfirmasi Kata Sandi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: 'Ulangi kata sandi',
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellowDark,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Lanjut'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final currentPin = _isConfirmingPin ? _confirmPinString : _pinString;
    
    return Column(
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else ...[
          Text(
            _isConfirmingPin ? 'Konfirmasi PIN Anda' : 'Buat PIN Keamanan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isConfirmingPin 
              ? 'Masukkan kembali PIN yang baru saja Anda buat' 
              : 'Masukkan 6 digit angka',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final isFilled = index < currentPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.primaryDark : AppColors.bgBlueLight,
                  border: Border.all(
                    color: isFilled ? AppColors.primaryDark : AppColors.textHint.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 32),
          
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (int i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
              const SizedBox(),
              _buildKeypadButton('0'),
              IconButton(
                onPressed: _onBackspace,
                icon: const Icon(Icons.backspace_outlined, color: AppColors.primaryDark),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                if (_isConfirmingPin) {
                  _isConfirmingPin = false;
                  _confirmPinString = '';
                  _pinString = '';
                } else {
                  _showPinStep = false;
                }
              });
            },
            child: const Text('Kembali'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.welcomeBg,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Back Button & Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_showPinStep) {
                          setState(() {
                            if (_isConfirmingPin) {
                              _isConfirmingPin = false;
                              _confirmPinString = '';
                              _pinString = '';
                            } else {
                              _showPinStep = false;
                            }
                          });
                        } else {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Text(
                  _showPinStep ? 'Keamanan\nAkun Anda.' : 'Buat akun,\ntanpa ribet.',
                  style: GoogleFonts.lora(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryDark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showPinStep 
                    ? 'Pastikan PIN yang Anda buat aman dan tidak dibagikan kepada siapapun.'
                    : 'Satu akun untuk bayar tagihan PBB dan orang\nterdekatmu.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 32),
                  
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showPinStep ? _buildStep2() : _buildStep1(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (!_showPinStep)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Masuk',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
