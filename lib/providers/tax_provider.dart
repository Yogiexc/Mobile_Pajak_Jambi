import 'package:flutter/material.dart';

class TaxBill {
  final String id;
  final String title;
  final String taxId;
  final double amount;
  final String status;
  final DateTime dueDate;

  TaxBill({
    required this.id,
    required this.title,
    required this.taxId,
    required this.amount,
    this.status = 'Belum Bayar',
    required this.dueDate,
  });
}

class TaxTransaction {
  final String id;
  final String title;
  final String taxId;
  final double amount;
  final DateTime date;
  final String bankName;
  final bool isSuccess;
  final bool isQris;

  TaxTransaction({
    required this.id,
    required this.title,
    required this.taxId,
    required this.amount,
    required this.date,
    required this.bankName,
    required this.isSuccess,
    required this.isQris,
  });
}

class TaxProvider extends ChangeNotifier {
  // Pending bills to show on Home
  final List<TaxBill> _pendingBills = [
    TaxBill(
      id: 'B1',
      title: 'Pajak PBB',
      taxId: '3314010301010020',
      amount: 1450000,
      dueDate: DateTime.now().add(const Duration(days: 90)),
    )
  ];

  // Transaction history to show on History
  final List<TaxTransaction> _history = [
    TaxTransaction(
      id: 'T1',
      title: 'Pajak PBB',
      taxId: '33180100010010010',
      amount: 1450000,
      date: DateTime.now().subtract(const Duration(days: 6)),
      bankName: 'Mandiri',
      isSuccess: false,
      isQris: false,
    ),
    TaxTransaction(
      id: 'T2',
      title: 'BPHTB',
      taxId: 'TR-2026-00123',
      amount: 88000,
      date: DateTime.now().subtract(const Duration(days: 6)),
      bankName: 'BCA',
      isSuccess: true,
      isQris: false,
    ),
    TaxTransaction(
      id: 'T3',
      title: 'PBJT Hotel',
      taxId: 'P.001234567890',
      amount: 550500,
      date: DateTime.now().subtract(const Duration(days: 10)),
      bankName: 'QRIS',
      isSuccess: true,
      isQris: true,
    ),
  ];

  String? _npwpd;
  final List<String> _nops = [];

  String? get npwpd => _npwpd;
  List<String> get nops => _nops;
  bool get hasNpwpd => _npwpd != null;

  List<TaxBill> get pendingBills => _pendingBills;
  List<TaxTransaction> get history => _history;

  // Derived getters for summary
  int get lunasCount => _history.where((t) => t.isSuccess).length;
  int get belumBayarCount => _pendingBills.length;
  double get totalTerbayar => _history
      .where((t) => t.isSuccess)
      .fold(0, (sum, t) => sum + t.amount);

  void addNpwpd(String npwpd) {
    if (_npwpd != null) return;
    _npwpd = npwpd;
    // Simulate finding active bills for this NPWPD
    final now = DateTime.now();
    _pendingBills.addAll([
      TaxBill(
        id: '${now.millisecondsSinceEpoch}_1',
        title: 'PBJT Makanan & Minuman',
        taxId: npwpd,
        amount: 450000,
        dueDate: now.add(const Duration(days: 14)),
      ),
      TaxBill(
        id: '${now.millisecondsSinceEpoch}_2',
        title: 'PBJT Perhotelan',
        taxId: npwpd,
        amount: 2500000,
        dueDate: now.add(const Duration(days: 14)),
      ),
    ]);
    notifyListeners();
  }

  void addNop(String nop) {
    if (!_nops.contains(nop)) {
      _nops.add(nop);
      _pendingBills.add(
        TaxBill(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Pajak PBB',
          taxId: nop,
          amount: 325000,
          dueDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );
      notifyListeners();
    }
  }

  // Generic method for transaction IDs (BPHTB)
  void addBill(String taxId, String serviceName) {
    _pendingBills.add(
      TaxBill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: serviceName,
        taxId: taxId,
        amount: 250000,
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    );
    notifyListeners();
  }

  void payBill(String id, String bankName, bool isQris) {
    final index = _pendingBills.indexWhere((b) => b.id == id);
    if (index != -1) {
      final bill = _pendingBills[index];
      // Add to history
      _history.insert(
        0,
        TaxTransaction(
          id: 'T_${DateTime.now().millisecondsSinceEpoch}',
          title: bill.title,
          taxId: bill.taxId,
          amount: bill.amount,
          date: DateTime.now(),
          bankName: bankName,
          isSuccess: true,
          isQris: isQris,
        ),
      );
      // Remove from pending
      _pendingBills.removeAt(index);
      notifyListeners();
    }
  }
}
