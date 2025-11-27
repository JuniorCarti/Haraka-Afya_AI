class PaymentModel {
  final String id;
  final String phoneNumber;
  final double amount;
  final String accountReference;
  final String transactionDesc;
  final DateTime timestamp;
  final PaymentStatus status;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final String? errorMessage;

  PaymentModel({
    required this.id,
    required this.phoneNumber,
    required this.amount,
    required this.accountReference,
    required this.transactionDesc,
    required this.timestamp,
    this.status = PaymentStatus.pending,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'accountReference': accountReference,
      'transactionDesc': transactionDesc,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'checkoutRequestId': checkoutRequestId,
      'merchantRequestId': merchantRequestId,
      'errorMessage': errorMessage,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      amount: map['amount'],
      accountReference: map['accountReference'],
      transactionDesc: map['transactionDesc'],
      timestamp: DateTime.parse(map['timestamp']),
      status: _parseStatus(map['status']),
      checkoutRequestId: map['checkoutRequestId'],
      merchantRequestId: map['merchantRequestId'],
      errorMessage: map['errorMessage'],
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

PaymentStatus _parseStatus(String status) {
  switch (status) {
    case 'PaymentStatus.completed':
      return PaymentStatus.completed;
    case 'PaymentStatus.processing':
      return PaymentStatus.processing;
    case 'PaymentStatus.failed':
      return PaymentStatus.failed;
    case 'PaymentStatus.cancelled':
      return PaymentStatus.cancelled;
    default:
      return PaymentStatus.pending;
  }
}