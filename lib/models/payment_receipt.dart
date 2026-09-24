class PaymentReceipt {
  final String transactionId;
  final String taxType;
  final String npwpd;
  final String taxPeriod;
  final String accountCode;
  final String accountDescription;
  final DateTime paymentDate;
  final String paymentReceiver;
  final String bankReference;
  final double taxAmount;
  final double penalty;
  final double totalAmount;
  final String amountInWords;
  final String paymentMethod;
  final String status;

  PaymentReceipt({
    required this.transactionId,
    required this.taxType,
    required this.npwpd,
    required this.taxPeriod,
    required this.accountCode,
    required this.accountDescription,
    required this.paymentDate,
    required this.paymentReceiver,
    required this.bankReference,
    required this.taxAmount,
    required this.penalty,
    required this.totalAmount,
    required this.amountInWords,
    required this.paymentMethod,
    required this.status,
  });
}
