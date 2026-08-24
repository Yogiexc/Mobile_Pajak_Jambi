import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';
import '../utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface, // Clean white bg matching figma
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.pagePadding,
            vertical: context.isSmallPhone ? 12 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profil',
                style: GoogleFonts.lora(
                  fontSize: context.sp(28),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 32),

              // Avatar & Profile Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgWhite,
                        border: Border.all(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'), // Use existing asset for now, or just an icon
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 50, color: AppColors.primaryDark), // Placeholder avatar
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dexa Wahnugrah',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+62 812-3456-7890',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8), // Light blue from figma
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Verified Account',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Akun Section
              _buildSection(
                title: 'Akun',
                items: [
                  _buildMenuItem(Icons.person_outline, 'Edit Profil'),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.account_balance_outlined, 'Rekening Bank'),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.credit_card_outlined, 'Kartu Tertaut'),
                ],
              ),
              const SizedBox(height: 24),

              // Pajak Terdaftar Section
              _buildSection(
                title: 'Pajak Terdaftar',
                items: taxProvider.pendingBills.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Belum ada pajak yang didaftarkan.',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        )
                      ]
                    : taxProvider.pendingBills.map((bill) {
                        final config = TaxConfigManager.getDetailConfig(bill.title);
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: config.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(config.icon, color: config.color, size: 20),
                              ),
                              title: Text(
                                bill.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    bill.taxId,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Jatuh Tempo: ${DateFormat('dd MMM yyyy', 'id_ID').format(bill.dueDate)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (bill != taxProvider.pendingBills.last) _buildMenuDivider(),
                          ],
                        );
                      }).toList(),
              ),
              const SizedBox(height: 24),

              // General Section
              _buildSection(
                title: 'General',
                items: [
                  _buildMenuItem(Icons.help_outline_rounded, 'Pusat Bantuan'),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.privacy_tip_outlined, 'Kebijakan Privasi'),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.description_outlined, 'Ketentuan Layanan'),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    Icons.logout_rounded,
                    'Logout',
                    textColor: AppColors.danger,
                    iconColor: AppColors.danger,
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header (Dark)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Section Items
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {Color? textColor, Color? iconColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textHint.withValues(alpha: 0.2)),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.primaryDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.textHint.withValues(alpha: 0.2),
      ),
    );
  }
}
