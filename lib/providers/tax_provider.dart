import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TaxBill {
  final String id;
  final String title;
  final String taxId;
  final String namaObjek;
  final double amount;
  final double denda;
  final String status;
  final DateTime dueDate;

  TaxBill({
    required this.id,
    required this.title,
    required this.taxId,
    this.namaObjek = '-',
    required this.amount,
    this.denda = 0,
    this.status = 'Belum Bayar',
    required this.dueDate,
  });
}

class TaxTransaction {
  final String id;
  final String title;
  final String taxId;
  final String namaObjek;
  final double amount;
  final double denda;
  final DateTime date;
  final String bankName;
  final bool isSuccess;
  final bool isQris;

  TaxTransaction({
    required this.id,
    required this.title,
    required this.taxId,
    this.namaObjek = '-',
    required this.amount,
    this.denda = 0,
    required this.date,
    required this.bankName,
    required this.isSuccess,
    required this.isQris,
  });
}

class LinkedBank {
  final String name;
  final String number;
  final bool isPrimary;

  LinkedBank({required this.name, required this.number, required this.isPrimary});
}

class TaxProvider extends ChangeNotifier {
  // Pending bills to show on Home
  final List<TaxBill> _pendingBills = [];

  // Transaction history to show on History
  final List<TaxTransaction> _history = [];

  String? _npwpd;
  final List<String> _nops = []; // Start empty

  // User Profile Data
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userPassword;
  String? userPin;
  String? userNik = '1571xxxxxxxxxxxx'; // Dummy NIK

  // Linked Banks Data
  final List<LinkedBank> _linkedBanks = [
    LinkedBank(name: 'Mandiri', number: '**** **** **** 4921', isPrimary: true),
    LinkedBank(name: 'BCA', number: '**** **** **** 1837', isPrimary: false),
  ];
  List<LinkedBank> get linkedBanks => _linkedBanks;

  TaxProvider() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    // Start fresh - data is populated dynamically when user adds NOP/NPWPD
  }

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
      .fold(0, (sum, t) => sum + t.amount + t.denda);

  Future<bool> registerUser({
    required String nik,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String pin,
  }) async {
    try {
      final response = await _apiService.post('/register', {
        'nik': nik,
        'full_name': name,
        'email': email,
        'phone_number': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'pin_number': pin,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        await _apiService.saveToken(token);
        
        userName = name;
        userEmail = email;
        userPhone = phone;
        userNik = nik;
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  final ApiService _apiService = ApiService();

  Future<bool> loginUser(String nik, String password) async {
    try {
      final response = await _apiService.post('/login', {
        'nik': nik,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Save token
        await _apiService.saveToken(token);
        
        // Update user state (using the data from API)
        userName = data['user']['full_name'];
        userNik = nik;
        
        // You might want to call _apiService.get('/summary') after login
        // to prefetch data, but for now we just return success.
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void updateProfile(String name, String email, String phone) {
    userName = name;
    userEmail = email;
    userPhone = phone;
    notifyListeners();
  }

  void addLinkedBank(String name, String number, bool isPrimary) {
    if (isPrimary) {
      // If adding a new primary bank, make others non-primary
      for (int i = 0; i < _linkedBanks.length; i++) {
        _linkedBanks[i] = LinkedBank(
          name: _linkedBanks[i].name, 
          number: _linkedBanks[i].number, 
          isPrimary: false
        );
      }
    }
    _linkedBanks.add(LinkedBank(name: name, number: number, isPrimary: isPrimary));
    notifyListeners();
  }

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
        namaObjek: 'Restoran Sedap Malam',
        amount: 450000,
        denda: 0,
        dueDate: now.add(const Duration(days: 14)),
      ),
      TaxBill(
        id: '${now.millisecondsSinceEpoch}_2',
        title: 'PBJT Hotel',
        taxId: npwpd,
        namaObjek: 'Hotel Jambi City',
        amount: 2500000,
        denda: 150000,
        dueDate: now.subtract(const Duration(days: 5)),
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
          namaObjek: 'Properti Baru',
          amount: 325000,
          denda: 0,
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
        namaObjek: 'Transaksi Baru',
        amount: 250000,
        denda: 0,
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
          namaObjek: bill.namaObjek,
          amount: bill.amount,
          denda: bill.denda,
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
