import 'package:flutter/material.dart';
import 'colors.dart';

class MainMenuConfig {
  final String title;
  final String inputLabel;
  final String hintText;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;

  const MainMenuConfig({
    required this.title,
    required this.inputLabel,
    required this.hintText,
    required this.icon,
    required this.color,
    this.keyboardType = TextInputType.text,
  });
}

class TaxConfig {
  final String title;
  final String inputLabel;
  final IconData icon;
  final Color color;

  const TaxConfig({
    required this.title,
    required this.inputLabel,
    required this.icon,
    required this.color,
  });
}

class TaxConfigManager {
  // 3 Main Menus for the Home Screen & Check Tax
  static const List<MainMenuConfig> mainMenus = [
    MainMenuConfig(
      title: 'Pajak PBB',
      inputLabel: 'Nomor Objek Pajak (NOP)',
      hintText: 'Contoh: 15.71.010.001.001-0123.0',
      icon: Icons.home_work,
      color: Colors.blue,
      keyboardType: TextInputType.number,
    ),
    MainMenuConfig(
      title: 'BPHTB',
      inputLabel: 'ID Transaksi',
      hintText: 'Contoh: TR-2026-00123',
      icon: Icons.receipt_long,
      color: AppColors.primaryDark,
    ),
    MainMenuConfig(
      title: 'Pajak Lainnya',
      inputLabel: 'NPWPD',
      hintText: 'Contoh: P.001234567890',
      icon: Icons.storefront,
      color: AppColors.yellowDark,
    ),
  ];

  // Detailed configs used when displaying the actual bills (Card & Profile)
  static const List<TaxConfig> detailConfigs = [
    TaxConfig(title: 'Pajak PBB', inputLabel: 'NOP', icon: Icons.home_work, color: Colors.blue),
    TaxConfig(title: 'BPHTB', inputLabel: 'ID Transaksi', icon: Icons.receipt_long, color: AppColors.primaryDark),
    TaxConfig(title: 'PBJT Hotel', inputLabel: 'NPWPD', icon: Icons.hotel, color: AppColors.yellowDark),
    TaxConfig(title: 'PBJT Makanan & Minuman', inputLabel: 'NPWPD', icon: Icons.restaurant, color: Colors.orange),
    TaxConfig(title: 'PBJT Parkir', inputLabel: 'NPWPD', icon: Icons.local_parking, color: Colors.teal),
    TaxConfig(title: 'PBJT Hiburan', inputLabel: 'NPWPD', icon: Icons.music_note, color: Colors.pinkAccent),
    TaxConfig(title: 'PBJT Listrik', inputLabel: 'NPWPD', icon: Icons.bolt, color: Colors.amber),
    TaxConfig(title: 'Pajak Reklame', inputLabel: 'NPWPD', icon: Icons.campaign, color: Colors.red),
    TaxConfig(title: 'Pajak Air Tanah', inputLabel: 'NPWPD', icon: Icons.water_drop, color: Colors.lightBlue),
    TaxConfig(title: 'Pajak Mineral', inputLabel: 'NPWPD', icon: Icons.landscape, color: Colors.brown),
    TaxConfig(title: 'Pajak Sarang Burung Walet', inputLabel: 'NPWPD', icon: Icons.eco, color: Colors.green),
  ];

  static MainMenuConfig getMainMenu(String title) {
    return mainMenus.firstWhere(
      (m) => m.title == title,
      orElse: () => mainMenus.last,
    );
  }

  static TaxConfig getDetailConfig(String title) {
    return detailConfigs.firstWhere(
      (c) => c.title == title,
      orElse: () => const TaxConfig(title: 'Pajak Daerah', inputLabel: 'Nomor', icon: Icons.receipt, color: Colors.grey),
    );
  }
}
