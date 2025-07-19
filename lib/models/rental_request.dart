enum RentalStatus { pending, approved, active, completed, rejected }

class RentalRequest {
  final String id;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String? licenseNumber;
  final List<Map<String, dynamic>> bikes;
  final DateTime submissionDate;
  final DateTime pickupDate;
  final DateTime returnDate;
  final double totalCost;
  final double deposit;
  final String paymentMethod;
  final String? promoCode;
  final RentalStatus status;
  final bool termsAccepted;
  final bool ageVerified;
  final bool damageResponsibility;
  final DateTime? approvalDate;
  final DateTime? actualPickupDate;
  final DateTime? actualReturnDate;
  final String? approvedBy;
  final String? rejectionReason;
  final Duration? activeTime;

  RentalRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.licenseNumber,
    required this.bikes,
    required this.submissionDate,
    required this.pickupDate,
    required this.returnDate,
    required this.totalCost,
    required this.deposit,
    required this.paymentMethod,
    this.promoCode,
    this.status = RentalStatus.pending,
    required this.termsAccepted,
    required this.ageVerified,
    required this.damageResponsibility,
    this.approvalDate,
    this.actualPickupDate,
    this.actualReturnDate,
    this.approvedBy,
    this.rejectionReason,
    this.activeTime,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
      licenseNumber: json['license_number'],
      bikes: List<Map<String, dynamic>>.from(json['bikes'] ?? []),
      submissionDate: DateTime.parse(json['submission_date']),
      pickupDate: DateTime.parse(json['pickup_date']),
      returnDate: DateTime.parse(json['return_date']),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'card',
      promoCode: json['promo_code'],
      status: RentalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RentalStatus.pending,
      ),
      termsAccepted: json['terms_accepted'] ?? false,
      ageVerified: json['age_verified'] ?? false,
      damageResponsibility: json['damage_responsibility'] ?? false,
      approvalDate:
          json['approval_date'] != null
              ? DateTime.parse(json['approval_date'])
              : null,
      actualPickupDate:
          json['actual_pickup_date'] != null
              ? DateTime.parse(json['actual_pickup_date'])
              : null,
      actualReturnDate:
          json['actual_return_date'] != null
              ? DateTime.parse(json['actual_return_date'])
              : null,
      approvedBy: json['approved_by'],
      rejectionReason: json['rejection_reason'],
      activeTime:
          json['active_time'] != null
              ? Duration(seconds: json['active_time'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'license_number': licenseNumber,
      'bikes': bikes,
      'submission_date': submissionDate.toIso8601String(),
      'pickup_date': pickupDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
      'total_cost': totalCost,
      'deposit': deposit,
      'payment_method': paymentMethod,
      'promo_code': promoCode,
      'status': status.toString().split('.').last,
      'terms_accepted': termsAccepted,
      'age_verified': ageVerified,
      'damage_responsibility': damageResponsibility,
      'approval_date': approvalDate?.toIso8601String(),
      'actual_pickup_date': actualPickupDate?.toIso8601String(),
      'actual_return_date': actualReturnDate?.toIso8601String(),
      'approved_by': approvedBy,
      'rejection_reason': rejectionReason,
      'active_time': activeTime?.inSeconds,
    };
  }

  RentalRequest copyWith({
    String? id,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? licenseNumber,
    List<Map<String, dynamic>>? bikes,
    DateTime? submissionDate,
    DateTime? pickupDate,
    DateTime? returnDate,
    double? totalCost,
    double? deposit,
    String? paymentMethod,
    String? promoCode,
    RentalStatus? status,
    bool? termsAccepted,
    bool? ageVerified,
    bool? damageResponsibility,
    DateTime? approvalDate,
    DateTime? actualPickupDate,
    DateTime? actualReturnDate,
    String? approvedBy,
    String? rejectionReason,
    Duration? activeTime,
  }) {
    return RentalRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bikes: bikes ?? this.bikes,
      submissionDate: submissionDate ?? this.submissionDate,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      totalCost: totalCost ?? this.totalCost,
      deposit: deposit ?? this.deposit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      status: status ?? this.status,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      ageVerified: ageVerified ?? this.ageVerified,
      damageResponsibility: damageResponsibility ?? this.damageResponsibility,
      approvalDate: approvalDate ?? this.approvalDate,
      actualPickupDate: actualPickupDate ?? this.actualPickupDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      activeTime: activeTime ?? this.activeTime,
    );
  }

  String get formattedSubmissionDate =>
      '${submissionDate.day}/${submissionDate.month}/${submissionDate.year}';
  String get formattedPickupDate =>
      '${pickupDate.day}/${pickupDate.month}/${pickupDate.year}';
  String get formattedReturnDate =>
      '${returnDate.day}/${returnDate.month}/${returnDate.year}';

  String get statusDisplayName {
    switch (status) {
      case RentalStatus.pending:
        return 'Pending';
      case RentalStatus.approved:
        return 'Approved';
      case RentalStatus.active:
        return 'Active';
      case RentalStatus.completed:
        return 'Completed';
      case RentalStatus.rejected:
        return 'Rejected';
    }
  }

  String get formattedActiveTime {
    if (activeTime == null) return '00:00:00';
    return '${activeTime!.inHours.toString().padLeft(2, '0')}:'
        '${(activeTime!.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(activeTime!.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String get bikesSummary {
    if (bikes.isEmpty) return 'No bikes selected';
    final bikeNames = bikes.map((b) => b['bike_model']).toSet().toList();
    if (bikeNames.length == 1) return '1 ${bikeNames.first}';
    return '${bikeNames.length} different bikes';
  }

  int get totalBikesCount {
    return bikes.fold(0, (sum, bike) => sum + (bike['quantity'] as int));
  }

  Duration get rentalDuration => returnDate.difference(pickupDate);
}
