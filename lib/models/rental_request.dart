import 'package:intl/intl.dart';

enum RentalStatus {
  pending,
  approved,
  active,
  completed,
  rejected;

  String get displayName {
    switch (this) {
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
}

class RentalRequest {
  final String id;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String? licenseNumber;
  final List<Map<String, dynamic>> bikes;
  final List<Map<String, dynamic>>? accessories;
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
  final String? centerName;
  final String? centerUuid;
  final String? notes;

  RentalRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.licenseNumber,
    required this.bikes,
    this.accessories,
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
    this.centerName,
    this.centerUuid,
    this.notes,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
      licenseNumber: json['license_number'],
      bikes: List<Map<String, dynamic>>.from(json['bikes'] ?? []),
      accessories:
          json['accessories'] != null
              ? List<Map<String, dynamic>>.from(json['accessories'])
              : null,
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
      centerName: json['center_name'] ?? json['centerName'],
      centerUuid: json['center_uuid'] ?? json['centerUuid'],
      notes: json['notes'],
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
      'accessories': accessories,
      'submission_date': submissionDate.toIso8601String(),
      'pickup_date': pickupDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
      'total_cost': totalCost,
      'deposit': deposit,
      'payment_method': paymentMethod,
      'promo_code': promoCode,
      'status': status.name,
      'terms_accepted': termsAccepted,
      'age_verified': ageVerified,
      'damage_responsibility': damageResponsibility,
      'approval_date': approvalDate?.toIso8601String(),
      'actual_pickup_date': actualPickupDate?.toIso8601String(),
      'actual_return_date': actualReturnDate?.toIso8601String(),
      'approved_by': approvedBy,
      'rejection_reason': rejectionReason,
      'active_time': activeTime?.inSeconds,
      'center_name': centerName,
      'center_uuid': centerUuid,
      'notes': notes,
    };
  }

  RentalRequest copyWith({
    String? id,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? licenseNumber,
    List<Map<String, dynamic>>? bikes,
    List<Map<String, dynamic>>? accessories,
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
    String? centerName,
    String? centerUuid,
    String? notes,
  }) {
    return RentalRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bikes: bikes ?? this.bikes,
      accessories: accessories ?? this.accessories,
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
      centerName: centerName ?? this.centerName,
      centerUuid: centerUuid ?? this.centerUuid,
      notes: notes ?? this.notes,
    );
  }

  // Helper method to find a specific bike in the booking
  Map<String, dynamic>? findBike(String bikeId) {
    try {
      return bikes.firstWhere((bike) => bike['bike_id'] == bikeId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to find a specific accessory in the booking
  Map<String, dynamic>? findAccessory(String accessoryId) {
    if (accessories == null) return null;
    try {
      return accessories!.firstWhere((acc) => acc['id'] == accessoryId);
    } catch (e) {
      return null;
    }
  }

  // Computed Getters
  String get formattedSubmissionDate =>
      DateFormat('dd/MM/yyyy').format(submissionDate);

  String get formattedPickupDate => DateFormat('dd/MM/yyyy').format(pickupDate);

  String get formattedReturnDate => DateFormat('dd/MM/yyyy').format(returnDate);

  String get formattedActiveTime {
    if (activeTime == null) return '00:00:00';
    return '${activeTime!.inHours.toString().padLeft(2, '0')}:'
        '${(activeTime!.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(activeTime!.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String get bikesSummary {
    if (bikes.isEmpty) return 'No bikes selected';
    final bikeNames =
        bikes.map((b) => b['bike_name'] ?? b['bike_model']).toSet().toList();
    if (bikeNames.length == 1) return '1 ${bikeNames.first}';
    return '${bikeNames.length} different bikes';
  }

  String get accessoriesSummary {
    if (accessories == null || accessories!.isEmpty) return 'No accessories';
    final accessoryNames = accessories!.map((a) => a['name']).toSet().toList();
    if (accessoryNames.length == 1) return '1 ${accessoryNames.first}';
    return '${accessoryNames.length} different accessories';
  }

  int get totalBikesCount {
    return bikes.fold(0, (sum, bike) => sum + (bike['quantity'] as int? ?? 1));
  }

  int get totalAccessoriesCount {
    if (accessories == null) return 0;
    return accessories!.fold(
      0,
      (sum, acc) => sum + (acc['quantity'] as int? ?? 1),
    );
  }

  Duration get rentalDuration => returnDate.difference(pickupDate);

  String get statusDisplayName => status.displayName;

  // Get total rental time for a specific bike
  Duration? bikeRentalDuration(String bikeId) {
    final bike = findBike(bikeId);
    if (bike == null || bike['actualPickupTime'] == null) return null;

    final pickupTime = bike['actualPickupTime'];
    final returnTime = bike['actualReturnTime'] ?? DateTime.now();
    return returnTime.difference(pickupTime);
  }

  // Get formatted rental time for a specific bike
  String? formattedBikeRentalTime(String bikeId) {
    final duration = bikeRentalDuration(bikeId);
    if (duration == null) return null;

    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  // Check if all bikes in the booking are returned
  bool get allBikesReturned {
    if (bikes.isEmpty) return false;
    return bikes.every((bike) => bike['actualReturnTime'] != null);
  }

  // Check if all accessories in the booking are returned
  bool get allAccessoriesReturned {
    if (accessories == null || accessories!.isEmpty) return true;
    return accessories!.every((acc) => acc['actualReturnTime'] != null);
  }

  // Check if all items (bikes and accessories) are returned
  bool get allItemsReturned {
    return allBikesReturned && allAccessoriesReturned;
  }

  // Check if some but not all bikes/accessories are picked up
  bool get hasPartiallyPickedUpItems {
    // Check if any bikes are picked up but not all
    final anyBikesPickedUp = bikes.any((b) => b['actualPickupTime'] != null);
    final allBikesPickedUp = bikes.every((b) => b['actualPickupTime'] != null);
    final bikesPartiallyPickedUp = anyBikesPickedUp && !allBikesPickedUp;

    // Check accessories if they exist
    bool accessoriesPartiallyPickedUp = false;
    if (accessories != null && accessories!.isNotEmpty) {
      final anyAccessoriesPickedUp = accessories!.any(
        (a) => a['actualPickupTime'] != null,
      );
      final allAccessoriesPickedUp = accessories!.every(
        (a) => a['actualPickupTime'] != null,
      );
      accessoriesPartiallyPickedUp =
          anyAccessoriesPickedUp && !allAccessoriesPickedUp;
    }

    return bikesPartiallyPickedUp || accessoriesPartiallyPickedUp;
  }

  // Check if any items are picked up
  bool get hasAnyPickedUpItems {
    final anyBikesPickedUp = bikes.any((b) => b['actualPickupTime'] != null);
    final anyAccessoriesPickedUp =
        accessories?.any((a) => a['actualPickupTime'] != null) ?? false;
    return anyBikesPickedUp || anyAccessoriesPickedUp;
  }

  // Check if all items are picked up
  bool get allItemsPickedUp {
    final allBikesPickedUp = bikes.every((b) => b['actualPickupTime'] != null);
    final allAccessoriesPickedUp =
        accessories?.every((a) => a['actualPickupTime'] != null) ?? true;
    return allBikesPickedUp && allAccessoriesPickedUp;
  }
}
