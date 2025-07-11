enum RentalStatus { pending, approved, active, completed, rejected }

class RentalRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String bicycleId;
  final String bicycleName;
  final String bicycleModel;
  final DateTime submissionDate;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final double totalCost;
  final RentalStatus status;
  final String? notes;
  final DateTime? approvalDate;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final String? approvedBy;
  final String? rejectionReason;
  final Duration? activeTime;

  RentalRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.bicycleId,
    required this.bicycleName,
    required this.bicycleModel,
    required this.submissionDate,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.totalCost,
    required this.status,
    this.notes,
    this.approvalDate,
    this.pickupDate,
    this.returnDate,
    this.approvedBy,
    this.rejectionReason,
    this.activeTime,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
      bicycleId: json['bicycle_id'] ?? '',
      bicycleName: json['bicycle_name'] ?? '',
      bicycleModel: json['bicycle_model'] ?? '',
      submissionDate: DateTime.parse(
        json['submission_date'] ?? DateTime.now().toIso8601String(),
      ),
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      durationDays: json['duration_days'] ?? 1,
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      status: RentalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => RentalStatus.pending,
      ),
      notes: json['notes'],
      approvalDate:
          json['approval_date'] != null
              ? DateTime.parse(json['approval_date'])
              : null,
      pickupDate:
          json['pickup_date'] != null
              ? DateTime.parse(json['pickup_date'])
              : null,
      returnDate:
          json['return_date'] != null
              ? DateTime.parse(json['return_date'])
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
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'bicycle_id': bicycleId,
      'bicycle_name': bicycleName,
      'bicycle_model': bicycleModel,
      'submission_date': submissionDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'duration_days': durationDays,
      'total_cost': totalCost,
      'status': status.toString().split('.').last,
      'notes': notes,
      'approval_date': approvalDate?.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'approved_by': approvedBy,
      'rejection_reason': rejectionReason,
      'active_time': activeTime?.inSeconds,
    };
  }

  RentalRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? bicycleId,
    String? bicycleName,
    String? bicycleModel,
    DateTime? submissionDate,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    double? totalCost,
    RentalStatus? status,
    String? notes,
    DateTime? approvalDate,
    DateTime? pickupDate,
    DateTime? returnDate,
    String? approvedBy,
    String? rejectionReason,
    Duration? activeTime,
  }) {
    return RentalRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      bicycleId: bicycleId ?? this.bicycleId,
      bicycleName: bicycleName ?? this.bicycleName,
      bicycleModel: bicycleModel ?? this.bicycleModel,
      submissionDate: submissionDate ?? this.submissionDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      approvalDate: approvalDate ?? this.approvalDate,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      activeTime: activeTime ?? this.activeTime,
    );
  }

  String get formattedSubmissionDate {
    return '${submissionDate.day}/${submissionDate.month}/${submissionDate.year}';
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

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
    final hours = activeTime!.inHours;
    final minutes = activeTime!.inMinutes % 60;
    final seconds = activeTime!.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
