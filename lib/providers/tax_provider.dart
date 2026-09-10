import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../constants/payment_options.dart';

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
  final String status;
  final bool isQris;
  final String transactionRef;
  final String? vaNumber;
  final String? qrString;
  final String? qrImageUrl;
  final DateTime? vaExpiredAt;
  final DateTime? qrExpiredAt;

  TaxTransaction({
    required this.id,
    required this.title,
    required this.taxId,
    this.namaObjek = '-',
    required this.amount,
    this.denda = 0,
    required this.date,
    required this.bankName,
    required this.status,
    required this.isQris,
    this.transactionRef = '',
    this.vaNumber,
    this.qrString,
    this.qrImageUrl,
    this.vaExpiredAt,
    this.qrExpiredAt,
  });

  bool get isSuccess => status == 'success';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed' || status == 'expired';

  String get statusLabel {
    return switch (status) {
      'success' => 'Berhasil',
      'pending' => 'Menunggu',
      'expired' => 'Kedaluwarsa',
      _ => 'Gagal',
    };
  }
}

class TaxNotification {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime sentAt;

  TaxNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.sentAt,
  });
}

class LinkedBank {
  final int id;
  final String name;
  final String number;
  final bool isPrimary;
  final String type;
  final String provider;

  LinkedBank({
    required this.id,
    required this.name,
    required this.number,
    required this.isPrimary,
    this.type = 'bank_transfer',
    this.provider = '',
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
  final List<TaxNotification> _notifications = [];
  int _unreadNotificationCount = 0;

  String? _npwpd;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userNik;
  bool _loggedIn = false;
  bool _loading = false;
  bool _onboardingComplete = false;
  TaxTransaction? lastTransaction;

  bool get isLoggedIn => _loggedIn;
  bool get isLoading => _loading;
  String? get npwpd => _npwpd;
  bool get hasNpwpd => _npwpd != null;
  bool get hasNop => _nops.isNotEmpty;
  bool get needsOnboarding => _loggedIn && !_onboardingComplete;
  List<TaxBill> get pendingBills => List.unmodifiable(_pendingBills);
  List<TaxTransaction> get history => List.unmodifiable(_history);
  List<LinkedBank> get linkedBanks => List.unmodifiable(_linkedBanks);
  List<String> get nops => List.unmodifiable(_nops);
  List<TaxNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount => _unreadNotificationCount;

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    if (userNik != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_skipped_$userNik', true);
    }
    notifyListeners();
  }

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
    await _api.post('/register', {
      'nik': nik,
      'full_name': name,
      'email': email,
      'phone_number': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'pin_number': pin,
    });
  }

  Future<void> loginUser(String nik, String password) async {
    final data = await _api.post('/login', {'nik': nik, 'password': password});

    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Login berhasil, tetapi token tidak diterima dari server.',
      );
    }
    await _api.setToken(token);
    _applyUser({...?_asMap(data['user']), 'nik': nik});
    _loggedIn = true;
    await _persistUser();
    await refreshDashboard();
  }

  Future<String?> requestOtp(String nik, String purpose, String channel) async {
    final data = await _api.post('/otp/request', {
      'nik': nik,
      'purpose': purpose,
      'channel': channel,
    });
    if (data is Map && data['otp_code'] != null) {
      return data['otp_code'].toString();
    }
    return null;
  }

  Future<void> verifyOtp(
    String nik,
    String purpose,
    String code, {
    String? newPassword,
    String? newPasswordConfirmation,
    String? newPin,
  }) async {
    final body = {'nik': nik, 'purpose': purpose, 'code': code};

    if (newPassword != null) {
      body['new_password'] = newPassword;
      body['new_password_confirmation'] =
          newPasswordConfirmation ?? newPassword;
    }

    if (newPin != null) {
      body['new_pin'] = newPin;
    }

    await _api.post('/otp/verify', body);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    await _api.post('/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });

    // Automatically log out since token for other devices is revoked and this one might be too depending on logic
    // But backend says "token lain otomatis logout". Current device token is kept.
  }

  Future<void> changePin(
    String currentPin,
    String newPin,
    String newPinConfirmation,
  ) async {
    await _api.post('/change-pin', {
      'current_pin': currentPin,
      'new_pin': newPin,
      'new_pin_confirmation': newPinConfirmation,
    });
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

  Future<void> updateProfile(String name, String email, String phone) async {
    try {
      await _api.post('/profile', {
        '_method': 'POST',
        'full_name': name,
        'email': email,
        'phone_number': phone,
      });

      userName = name;
      userEmail = email;
      userPhone = phone;
      _persistUser();
      notifyListeners();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw const ApiException(
        'Gagal memperbarui profil. Periksa koneksi internet Anda.',
      );
    }
  }

  Future<void> addLinkedBank({
    required String provider,
    required String type,
    bool isPrimary = false,
  }) async {
    await _api.post('/payment-methods', {
      'type': type,
      'provider': provider,
      'is_default': isPrimary,
    });
    await _loadPaymentMethods();
    notifyListeners();
  }

  Future<LinkedBank> ensurePaymentMethod({
    required String provider,
    required String type,
  }) async {
    final existing = _linkedBanks.where(
      (b) =>
          b.provider.toLowerCase() == provider.toLowerCase() && b.type == type,
    );
    if (existing.isNotEmpty) return existing.first;

    await _api.post('/payment-methods', {
      'type': type,
      'provider': provider,
      'is_default': _linkedBanks.isEmpty,
    });
    await _loadPaymentMethods();
    notifyListeners();
    return _linkedBanks.firstWhere(
      (b) =>
          b.provider.toLowerCase() == provider.toLowerCase() && b.type == type,
    );
  }

  Future<Map<String, dynamic>> checkNop(String nop) async {
    return _asMap(await _api.post('/nops/check', {'nop_number': nop.trim()})) ??
        (throw const ApiException('Respons cek NOP tidak valid.'));
  }

  Future<Map<String, dynamic>> checkNpwpd(String npwpd) async {
    return _asMap(
          await _api.post('/npwpd/check', {'npwpd_number': npwpd.trim()}),
        ) ??
        (throw const ApiException('Respons cek NPWPD tidak valid.'));
  }

  Future<void> addNpwpd(String npwpd) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.post('/npwpd', {'npwpd_number': npwpd.trim()});
      await _loadNpwpd();
      if (!_onboardingComplete) _onboardingComplete = _nops.isNotEmpty || _npwpd != null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addNop(String nop) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.post('/nops', {'nop_number': nop.trim()});
      await _loadNops();
      if (!_onboardingComplete) _onboardingComplete = _nops.isNotEmpty || _npwpd != null;
    } finally {
      _loading = false;
      notifyListeners();
    }
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
    required String pin,
    required String paymentChannel,
    String? bankCode,
    int? paymentId,
    String? bankName,
  }) async {
    final body = <String, dynamic>{
      'id_bill': int.parse(billId),
      'payment_channel': paymentChannel,
      'pin': pin,
      'idempotency_key': _uuid.v4(),
    };
    if (paymentChannel == 'bank_transfer' && bankCode != null) {
      body['bank_code'] = bankCode;
    }
    if (paymentId != null) {
      body['id_payment'] = paymentId;
    }

    final initiated =
        ApiClient.unwrap(await _api.post('/transactions/initiate', body))
            as Map<String, dynamic>;

    lastTransaction = _mapTransaction(
      initiated,
      fallbackBank: bankName,
      fallbackQris: paymentChannel == 'qris',
    );
    
    // Partial refresh
    _loading = true;
    notifyListeners();
    try {
      final bill = _pendingBills.cast<TaxBill?>().firstWhere((b) => b?.id == billId, orElse: () => null);
      
      final futures = <Future>[_loadTransactions()];
      if (bill != null) {
        if (bill.title == 'Pajak PBB') {
          futures.add(_loadNops());
        } else {
          futures.add(_loadNpwpd());
        }
      } else {
        futures.add(_loadNops());
        futures.add(_loadNpwpd());
      }
      
      await Future.wait(futures);
    } finally {
      _loading = false;
      notifyListeners();
    }
    
    return lastTransaction!;
  }

  Future<TaxTransaction> fetchTransaction(String id) async {
    final data =
        ApiClient.unwrap(await _api.get('/transactions/$id'))
            as Map<String, dynamic>;
    lastTransaction = _mapTransaction(data);
    notifyListeners();
    return lastTransaction!;
  }

  Future<TaxTransaction> simulatePayment(String id) async {
    final data =
        ApiClient.unwrap(await _api.post('/transactions/$id/simulate-payment'))
            as Map<String, dynamic>;
    lastTransaction = _mapTransaction(data);
    notifyListeners();
    return lastTransaction!;
  }

  void inspectTransaction(TaxTransaction tx) {
    lastTransaction = tx;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    if (!_loggedIn) return;
    _loading = true;
    notifyListeners();
    try {
      _pendingBills.clear();
      await Future.wait([
        _loadOnboarding(),
        _loadNops(),
        _loadNpwpd(),
        _loadPaymentMethods(),
        _loadTransactions(),
        _loadNotifications(),
      ]);
      if (!_onboardingComplete) {
        _onboardingComplete = _nops.isNotEmpty || _npwpd != null;
        if (!_onboardingComplete && userNik != null) {
          final prefs = await SharedPreferences.getInstance();
          _onboardingComplete = prefs.getBool('onboarding_skipped_$userNik') ?? false;
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadOnboarding() async {
    try {
      final data = await _api.get('/me/onboarding-status');
      if (data is Map) {
        _onboardingComplete = data['onboarding_complete'] == true;
      }
    } catch (_) {
      // Fallback di refreshDashboard dari daftar NOP/NPWPD.
    }
  }

  Future<void> _loadNops() async {
    final data = ApiClient.unwrap(await _api.get('/nops'));
    _nops.clear();
    _pendingBills.removeWhere((b) => b.title == 'Pajak PBB');

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
    _pendingBills.removeWhere((b) => b.title != 'Pajak PBB');

    final map = _asMap(data);
    if (map != null) {
      _npwpd = map['npwpd_number']?.toString();
      _appendBills(
        bills: map['bills'],
        title: map['business_type']?.toString() ?? 'Pajak Usaha',
        taxId: _npwpd ?? '',
        namaObjek: map['business_name']?.toString() ?? 'Usaha',
      );
    }
  }

  Future<void> _loadPaymentMethods() async {
    final data = ApiClient.unwrap(await _api.get('/payment-methods'));
    _linkedBanks.clear();
    if (data is List) {
      for (final item in data) {
        final map = item as Map<String, dynamic>;
        final provider = map['provider']?.toString() ?? '';
        _linkedBanks.add(
          LinkedBank(
            id: _asInt(map['id_payment']),
            name: PaymentOptions.labelFor(provider),
            number: map['type_label']?.toString() ?? '-',
            isPrimary: map['is_default'] == true,
            type: map['type']?.toString() ?? 'bank_transfer',
            provider: provider,
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

  Future<void> _loadNotifications() async {
    try {
      final unreadData = await _api.get('/notifications/unread-count');
      _unreadNotificationCount = ApiClient.unwrap(unreadData)['unread_count'] as int? ?? 0;
    } catch (e) {
      debugPrint('Failed to load unread count: $e');
    }

    try {
      final data = ApiClient.unwrap(await _api.get('/notifications'));
      _notifications.clear();
      if (data is List) {
        for (final item in data) {
          final notif = item as Map<String, dynamic>;
          _notifications.add(
            TaxNotification(
              id: notif['id'] as int,
              title: notif['title']?.toString() ?? 'Pemberitahuan',
              message: notif['message']?.toString() ?? '',
              isRead: (notif['is_read'] as bool?) ?? false,
              sentAt: DateTime.tryParse(notif['sent_at']?.toString() ?? '') ?? DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _api.post('/notifications/$id/read');
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post('/notifications/read-all');
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      // Ignored
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
          dueDate:
              DateTime.tryParse(bill['due_date']?.toString() ?? '') ??
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
    final paidAt =
        DateTime.tryParse(map['paid_at']?.toString() ?? '') ??
        DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.now();
    final channel = map['payment_channel']?.toString();
    final paymentProvider = payment is Map
        ? payment['provider']?.toString()
        : null;

    return TaxTransaction(
      id: map['id_transactions'].toString(),
      title: map['tax_type_label']?.toString() ?? 'Pajak Daerah',
      taxId: '',
      namaObjek: map['object_name']?.toString() ?? '-',
      amount: _asDouble(map['amount']),
      denda: bill is Map ? _asDouble(bill['penalty_amount']) : 0,
      date: paidAt,
      bankName:
          map['bank_label']?.toString() ??
          (paymentProvider != null
              ? PaymentOptions.labelFor(paymentProvider)
              : null) ??
          map['payment_channel_label']?.toString() ??
          fallbackBank ??
          '-',
      status: map['status']?.toString() ?? 'pending',
      isQris: channel == 'qris' || fallbackQris,
      transactionRef: map['transaction_ref']?.toString() ?? '',
      vaNumber: map['va_number']?.toString(),
      qrString: map['qr_string']?.toString(),
      qrImageUrl: map['qr_image_url']?.toString(),
      vaExpiredAt: DateTime.tryParse(map['va_expired_at']?.toString() ?? ''),
      qrExpiredAt: DateTime.tryParse(map['qr_expired_at']?.toString() ?? ''),
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
    _onboardingComplete = false;
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
}
