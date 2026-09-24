import 'package:flutter/material.dart';

enum PaymentStatus { lunas, belumBayar, pending }

class TaxTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final PaymentStatus status;
  final String category;

  TaxTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.category,
  });
}

class TaxService {
  final String name;
  final IconData icon;
  final Color color;
  final String route;

  TaxService({
    required this.name,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class TaxDetail {
  final String id;
  final String taxType;
  final String objectName;
  final String nop;
  final int year;
  final double njop;
  final double taxAmount;
  final double penalty;
  final double totalAmount;
  final PaymentStatus status;
  final DateTime dueDate;
  final List<TaxBreakdownItem> breakdown;

  TaxDetail({
    required this.id,
    required this.taxType,
    required this.objectName,
    required this.nop,
    required this.year,
    required this.njop,
    required this.taxAmount,
    required this.penalty,
    required this.totalAmount,
    required this.status,
    required this.dueDate,
    required this.breakdown,
  });
}

class TaxBreakdownItem {
  final String label;
  final double value;

  TaxBreakdownItem({required this.label, required this.value});
}

// Sample Data
class SampleData {
  static List<TaxService> services = [
    TaxService(
      name: 'PKB',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF3B82F6),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'PBB',
      icon: Icons.home_rounded,
      color: const Color(0xFF10B981),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'BPHTB',
      icon: Icons.description_rounded,
      color: const Color(0xFFF59E0B),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'Restoran',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFEF4444),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'Hotel',
      icon: Icons.hotel_rounded,
      color: const Color(0xFF8B5CF6),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'Hiburan',
      icon: Icons.celebration_rounded,
      color: const Color(0xFFEC4899),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'Parkir',
      icon: Icons.local_parking_rounded,
      color: const Color(0xFF06B6D4),
      route: '/detail-pajak',
    ),
    TaxService(
      name: 'Pajak Lainnya',
      icon: Icons.more_horiz_rounded,
      color: const Color(0xFF6B7280),
      route: '/detail-pajak',
    ),
  ];

  static List<TaxTransaction> transactions = [
    TaxTransaction(
      id: 'TRX001',
      title: 'Pajak Kendaraan Bermotor',
      description: 'BH 1234 AB - Honda Vario 150',
      amount: 250000,
      date: DateTime(2026, 8, 15),
      status: PaymentStatus.lunas,
      category: 'PKB',
    ),
    TaxTransaction(
      id: 'TRX002',
      title: 'Pajak Bumi dan Bangunan',
      description: 'NOP: 15.71.010.001.234-0001.0',
      amount: 1500000,
      date: DateTime(2026, 8, 10),
      status: PaymentStatus.belumBayar,
      category: 'PBB',
    ),
    TaxTransaction(
      id: 'TRX003',
      title: 'Pajak Restoran',
      description: 'RM Pindang Meranjat - Juli 2026',
      amount: 750000,
      date: DateTime(2026, 7, 28),
      status: PaymentStatus.lunas,
      category: 'Restoran',
    ),
    TaxTransaction(
      id: 'TRX004',
      title: 'Pajak Hotel',
      description: 'Hotel Jambi Indah - Agustus 2026',
      amount: 2300000,
      date: DateTime(2026, 8, 5),
      status: PaymentStatus.pending,
      category: 'Hotel',
    ),
    TaxTransaction(
      id: 'TRX005',
      title: 'BPHTB',
      description: 'Tanah Jl. Sultan Thaha No. 45',
      amount: 5000000,
      date: DateTime(2026, 7, 20),
      status: PaymentStatus.lunas,
      category: 'BPHTB',
    ),
  ];

  static TaxDetail sampleDetail = TaxDetail(
    id: 'DTL001',
    taxType: 'Pajak Bumi dan Bangunan',
    objectName: 'Rumah Tinggal - Jl. Jend. Sudirman No. 88',
    nop: '15.71.010.001.234-0001.0',
    year: 2026,
    njop: 350000000,
    taxAmount: 1400000,
    penalty: 100000,
    totalAmount: 1500000,
    status: PaymentStatus.belumBayar,
    dueDate: DateTime(2026, 9, 30),
    breakdown: [
      TaxBreakdownItem(label: 'NJOP Bumi', value: 200000000),
      TaxBreakdownItem(label: 'NJOP Bangunan', value: 150000000),
      TaxBreakdownItem(label: 'NJOPTKP', value: -10000000),
      TaxBreakdownItem(label: 'NJOP Kena Pajak', value: 340000000),
      TaxBreakdownItem(label: 'PBB Terutang (0.2%)', value: 1400000),
      TaxBreakdownItem(label: 'Denda Keterlambatan', value: 100000),
    ],
  );
}
