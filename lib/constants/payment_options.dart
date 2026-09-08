class PaymentBankOption {
  final String code;
  final String label;

  const PaymentBankOption(this.code, this.label);
}

class PaymentOptions {
  static const banks = [
    PaymentBankOption('bank_jambi', 'Bank Jambi'),
    PaymentBankOption('mandiri', 'Bank Mandiri'),
    PaymentBankOption('bri', 'Bank BRI'),
    PaymentBankOption('bni', 'Bank BNI'),
    PaymentBankOption('btn', 'Bank BTN'),
  ];

  static String labelFor(String? provider) {
    return switch (provider) {
      'bank_jambi' => 'Bank Jambi',
      'mandiri' => 'Bank Mandiri',
      'bri' => 'Bank BRI',
      'bni' => 'Bank BNI',
      'btn' => 'Bank BTN',
      'qris' => 'QRIS',
      _ => provider ?? 'Metode',
    };
  }
}
