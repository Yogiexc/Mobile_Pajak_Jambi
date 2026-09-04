import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class PinScreen extends StatefulWidget {
  final Map<String, dynamic> paymentArgs;

  const PinScreen({super.key, required this.paymentArgs});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';

  void _onNumberTap(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
      });
      
      if (_pin.length == 6) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _submitPin() {
    final pin = _pin;
    setState(() => _pin = '');
    context.push('/processing', extra: {
      ...widget.paymentArgs,
      'pin': pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'Masukkan PIN',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan 6 digit PIN untuk melanjutkan',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 24,
                  height: 24,
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
            const Spacer(),
            // Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 32,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
                  const SizedBox(), // Empty spot
                  _buildKeypadButton('0'),
                  IconButton(
                    onPressed: _onBackspace,
                    icon: const Icon(Icons.backspace_outlined, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          number,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}
