import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';

class TaxBill {
  final String id;
  final String title;
  final String taxId;
  final String namaObjek;
  final double amount;
  final double denda;
  final String status;
  final DateTime dueDate;
  final String taxPeriod;

  TaxBill({
    required this.id,
    required this.title,
    required this.taxId,
    this.namaObjek = '-',
    required this.amount,
    this.denda = 0,
    this.status = 'Belum Bayar',
    required this.dueDate,
    this.taxPeriod = '-',
  });

  double get total => amount + denda;
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
  final String transactionRef;

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
    this.transactionRef = '',
  });
}

class LinkedBank {
  final int id;
  final String name;
  final String number;
  final bool isPrimary;
  final String type;

  LinkedBank({
    required this.id,
    required this.name,
    required this.number,
    required this.isPrimary,
    this.type = 'bank_transfer',
  });
}

class TaxProvider extends ChangeNotifier {
  static const _userKey = 'auth_user';

  final ApiClient _api = ApiClient.instance;
  final _uuid = const Uuid();

  final List<TaxBill> _pendingBills = [];
  final List<TaxTransaction> _history = [];
  final List<LinkedBank> _linkedBanks = [];
  final List<String> _nops = [];

  String? _npwpd;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userNik;
  bool _loggedIn = false;
  bool _loading = false;
  TaxTransaction? lastTransaction;

  bool get isLoggedIn => _loggedIn;
  bool get isLoading => _loading;
  String? get npwpd => _npwpd;
  List<String> get nops => _nops;
  bool get hasNpwpd => _npwpd != null;
  bool get hasNop => _nops.isNotEmpty;
  bool get needsOnboarding => _loggedIn && !hasNop && !hasNpwpd;
  List<TaxBill> get pendingBills => _pendingBills;
  List<TaxTransaction> get history => _history;
  List<LinkedBank> get linkedBanks => _linkedBanks;

  int get lunasCount => _history.where((t) => t.isSuccess).length;
  int get belumBayarCount => _pendingBills.length;
  double get totalTerbayar => _history
      .where((t) => t.isSuccess)
      .fold(0, (sum, t) => sum + t.amount + t.denda);

  Future<void> bootstrap() async {
    await _api.init();
    _api.onUnauthorized = () {
      _clearSession();
      notifyListeners();
    };

    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);
    if (_api.hasToken && rawUser != null) {
      _applyUser(jsonDecode(rawUser) as Map<String, dynamic>);
      _loggedIn = true;
      try {
        await refreshDashboard();
      } on ApiException {
        await logout();
      }
    }
  }

  Future<void> registerUser(
    String name,
    String email,
    String phone,
    String password,
    String pin, {
    required String nik,
    required String passwordConfirmation,
  }) async {
    final data = await _api.post('/register', {
      'nik': nik,
      'full_name': name,
      'email': email,
      'phone_number': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'pin_number': pin,
    });

    await _api.setToken(data['token'] as String);
    _applyUser({
      'id_user': data['user']?['id_user'],
      'full_name': name,
      'email': email,
      'phone_number': phone,
      'nik': nik,
      'has_nop': false,
      'has_npwpd': false,
    });
    _loggedIn = true;
    await _persistUser();
    notifyListeners();
  }

  Future<void> loginUser(String nik, String password) async {
    final data = await _api.post('/login', {
      'nik': nik,
      'password': password,
    });

    await _api.setToken(data['token'] as String);
    _applyUser({
      ...?_asMap(data['user']),
      'nik': nik,
    });
    _loggedIn = true;
    await _persistUser();
    await refreshDashboard();
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // Token mungkin sudah invalid; tetap bersihkan sesi lokal.
    }
    await _api.clearToken();
    _clearSession();
    notifyListeners();
  }

  void updateProfile(String name, String email, String phone) {
    userName = name;
    userEmail = email;
    userPhone = phone;
    _persistUser();
    notifyListeners();
  }

  Future<void> addLinkedBank(String name, String number, bool isPrimary) async {
    await _api.post('/payment-methods', {
      'type': 'bank_transfer',
      'provider': name,
      'masked_number': _maskNumber(number),
      'is_default': isPrimary,
    });
    await _loadPaymentMethods();
    notifyListeners();
  }

  Future<LinkedBank> ensurePaymentMethod({
    required String provider,
    required String type,
    String? maskedNumber,
  }) async {
    final existing = _linkedBanks.where(
      (b) => b.name.toLowerCase() == provider.toLowerCase() && b.type == type,
    );
    if (existing.isNotEmpty) return existing.first;

    await _api.post('/payment-methods', {
      'type': type,
      'provider': provider,
      'masked_number': maskedNumber,
      'is_default': _linkedBanks.isEmpty,
    });
    await _loadPaymentMethods();
    notifyListeners();
    return _linkedBanks.firstWhere(
      (b) => b.name.toLowerCase() == provider.toLowerCase() && b.type == type,
    );
  }

  Future<void> addNpwpd(String npwpd) async {
    await _api.post('/npwpd', {'npwpd_number': npwpd.trim()});
    await refreshDashboard();
  }

  Future<void> addNop(String nop) async {
    await _api.post('/nops', {'nop_number': nop.trim()});
    await refreshDashboard();
  }

  Future<void> addBill(String taxId, String serviceName) async {
    final lower = serviceName.toLowerCase();
    if (lower.contains('pbb') || lower.contains('nop')) {
      await addNop(taxId);
      return;
    }
    if (lower.contains('bphtb')) {
      throw const ApiException(
        'Pencarian BPHTB belum tersedia di backend saat ini.',
      );
    }
    await addNpwpd(taxId);
  }

  Future<TaxTransaction> payBill({
    required String billId,
    required int paymentId,
    required String pin,
    required String bankName,
    required bool isQris,
  }) async {
    final initiated = ApiClient.unwrap(
      await _api.post('/transactions/initiate', {
        'id_bill': int.parse(billId),
        'id_payment': paymentId,
        'idempotency_key': _uuid.v4(),
      }),
    ) as Map<String, dynamic>;

    final txId = initiated['id_transactions'];
    final confirmed = ApiClient.unwrap(
      await _api.post('/transactions/$txId/confirm-pin', {'pin': pin}),
    ) as Map<String, dynamic>;

    lastTransaction = _mapTransaction(confirmed, fallbackBank: bankName, fallbackQris: isQris);
    await refreshDashboard();
    return lastTransaction!;
  }

  Future<void> refreshDashboard() async {
    if (!_loggedIn) return;
    _loading = true;
    notifyListeners();
    try {
      _pendingBills.clear();
      await Future.wait([
        _loadNops(),
        _loadNpwpd(),
        _loadPaymentMethods(),
        _loadTransactions(),
      ]);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNops() async {
    final data = ApiClient.unwrap(await _api.get('/nops'));
    _nops.clear();

    if (data is List) {
      for (final item in data) {
        final nop = item as Map<String, dynamic>;
        final number = nop['nop_number']?.toString() ?? '';
        if (number.isNotEmpty) _nops.add(number);
        _appendBills(
          bills: nop['bills'],
          title: 'Pajak PBB',
          taxId: number,
          namaObjek: nop['object_name']?.toString() ?? 'Properti',
        );
      }
    }
  }

  Future<void> _loadNpwpd() async {
    final raw = await _api.get('/npwpd');
    final data = ApiClient.unwrap(raw);
    _npwpd = null;

    if (data is Map<String, dynamic>) {
      _npwpd = data['npwpd_number']?.toString();
      _appendBills(
        bills: data['bills'],
        title: data['business_type']?.toString() ?? 'Pajak Usaha',
        taxId: _npwpd ?? '',
        namaObjek: data['business_name']?.toString() ?? 'Usaha',
      );
    }
  }

  Future<void> _loadPaymentMethods() async {
    final data = ApiClient.unwrap(await _api.get('/payment-methods'));
    _linkedBanks.clear();
    if (data is List) {
      for (final item in data) {
        final map = item as Map<String, dynamic>;
        _linkedBanks.add(
          LinkedBank(
            id: _asInt(map['id_payment']),
            name: map['provider']?.toString() ?? 'Metode',
            number: map['masked_number']?.toString() ?? '-',
            isPrimary: map['is_default'] == true,
            type: map['type']?.toString() ?? 'bank_transfer',
          ),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    final data = ApiClient.unwrap(await _api.get('/transactions'));
    _history.clear();
    if (data is List) {
      for (final item in data) {
        _history.add(_mapTransaction(item as Map<String, dynamic>));
      }
    }
  }

  void _appendBills({
    required dynamic bills,
    required String title,
    required String taxId,
    required String namaObjek,
  }) {
    if (bills is! List) return;
    for (final item in bills) {
      final bill = item as Map<String, dynamic>;
      final status = bill['status']?.toString() ?? 'unpaid';
      if (status == 'paid') continue;
      _pendingBills.add(
        TaxBill(
          id: bill['id_bills'].toString(),
          title: title,
          taxId: taxId,
          namaObjek: namaObjek,
          amount: _asDouble(bill['amount_due']),
          denda: _asDouble(bill['penalty_amount']),
          status: bill['status_label']?.toString() ?? 'Belum Bayar',
          dueDate: DateTime.tryParse(bill['due_date']?.toString() ?? '') ??
              DateTime.now(),
          taxPeriod: bill['tax_period']?.toString() ?? '-',
        ),
      );
    }
  }

  TaxTransaction _mapTransaction(
    Map<String, dynamic> map, {
    String? fallbackBank,
    bool fallbackQris = false,
  }) {
    final payment = map['payment_method'];
    final bill = map['bill'];
    final paidAt = DateTime.tryParse(map['paid_at']?.toString() ?? '') ??
        DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.now();

    return TaxTransaction(
      id: map['id_transactions'].toString(),
      title: map['tax_type_label']?.toString() ?? 'Pajak Daerah',
      taxId: '',
      namaObjek: map['object_name']?.toString() ?? '-',
      amount: _asDouble(map['amount']),
      denda: bill is Map ? _asDouble(bill['penalty_amount']) : 0,
      date: paidAt,
      bankName: payment is Map
          ? (payment['provider']?.toString() ?? fallbackBank ?? '-')
          : (fallbackBank ?? '-'),
      isSuccess: map['status'] == 'success',
      isQris: payment is Map
          ? payment['type'] == 'qris'
          : fallbackQris,
      transactionRef: map['transaction_ref']?.toString() ?? '',
    );
  }

  void _applyUser(Map<String, dynamic> user) {
    userName = user['full_name']?.toString() ?? userName;
    userEmail = user['email']?.toString() ?? userEmail;
    userPhone = user['phone_number']?.toString() ?? userPhone;
    userNik = user['nik']?.toString() ?? userNik;
  }

  Future<void> _persistUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userKey,
      jsonEncode({
        'full_name': userName,
        'email': userEmail,
        'phone_number': userPhone,
        'nik': userNik,
      }),
    );
  }

  void _clearSession() {
    _loggedIn = false;
    _pendingBills.clear();
    _history.clear();
    _linkedBanks.clear();
    _nops.clear();
    _npwpd = null;
    userName = null;
    userEmail = null;
    userPhone = null;
    userNik = null;
    lastTransaction = null;
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_userKey));
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _maskNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    return '**** ${digits.substring(digits.length - 4)}';
  }
}
