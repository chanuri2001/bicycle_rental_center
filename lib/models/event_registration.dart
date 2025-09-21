enum EventRegistrationStatus {
  pending,
  approved,
  rejected,
  confirmed,
  completed,
  cancelled,
}

class EventRegistration {
  final String id;
  final String eventId;
  final String participantName;
  final String participantEmail;
  final String participantPhone;
  final int age;
  final int count;
  final String emergencyContact;
  final String emergencyPhone;
  final String medicalConditions;
  final String experienceLevel;
  final DateTime submissionDate;
  final EventRegistrationStatus status;
  final String? rejectionReason;
  final DateTime? approvalDate;
  final DateTime? confirmationDate;
  final DateTime? completionDate;
  final bool hasAttended;
  final String? notes;
  final Map<String, dynamic> additionalInfo;



  EventRegistration({
    required this.id,
    required this.eventId,
    required this.participantName,
    required this.participantEmail,
    required this.participantPhone,
    required this.age,
    required this.count,
    required this.emergencyContact,
    required this.emergencyPhone,
    this.medicalConditions = '',
    required this.experienceLevel,
    required this.submissionDate,
    required this.status,
    this.rejectionReason,
    this.approvalDate,
    this.confirmationDate,
    this.completionDate,
    this.hasAttended = false,
    this.notes,
    this.additionalInfo = const {},
  });

  EventRegistration copyWith({
    String? id,
    String? eventId,
    String? participantName,
    String? participantEmail,
    String? participantPhone,
    int? age,
    int?count,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalConditions,
    String? experienceLevel,
    DateTime? submissionDate,
    EventRegistrationStatus? status,
    String? rejectionReason,
    DateTime? approvalDate,
    DateTime? confirmationDate,
    DateTime? completionDate,
    bool? hasAttended,
    String? notes,
    Map<String, dynamic>? additionalInfo,
  }) {
    return EventRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      participantPhone: participantPhone ?? this.participantPhone,
      age: age ?? this.age,
      count: count ?? this.count,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
      confirmationDate: confirmationDate ?? this.confirmationDate,
      completionDate: completionDate ?? this.completionDate,
      hasAttended: hasAttended ?? this.hasAttended,
      notes: notes ?? this.notes,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'] ?? '',
      eventId: json['event_id'] ?? '',
      participantName: json['participant_name'] ?? '',
      participantEmail: json['participant_email'] ?? '',
      participantPhone: json['participant_phone'] ?? '',
      age: json['age'] ?? 0,
      count: json['count']?? 0,
      emergencyContact: json['emergency_contact'] ?? '',
      emergencyPhone: json['emergency_phone'] ?? '',
      medicalConditions: json['medical_conditions'] ?? '',
      experienceLevel: json['experience_level'] ?? '',
      submissionDate: DateTime.parse(
        json['submission_date'] ?? DateTime.now().toIso8601String(),
      ),
      status: EventRegistrationStatus.values.firstWhere(
        (e) => e.toString() == 'EventRegistrationStatus.${json['status']}',
        orElse: () => EventRegistrationStatus.pending,
      ),
      rejectionReason: json['rejection_reason'],
      approvalDate:
          json['approval_date'] != null
              ? DateTime.parse(json['approval_date'])
              : null,
      confirmationDate:
          json['confirmation_date'] != null
              ? DateTime.parse(json['confirmation_date'])
              : null,
      completionDate:
          json['completion_date'] != null
              ? DateTime.parse(json['completion_date'])
              : null,
      hasAttended: json['has_attended'] ?? false,
      notes: json['notes'],
      additionalInfo: Map<String, dynamic>.from(json['additional_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'participant_name': participantName,
      'participant_email': participantEmail,
      'participant_phone': participantPhone,
      'age': age,
      'count': count,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'medical_conditions': medicalConditions,
      'experience_level': experienceLevel,
      'submission_date': submissionDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'confirmation_date': confirmationDate?.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'has_attended': hasAttended,
      'notes': notes,
      'additional_info': additionalInfo,
    };
  }

  String get activityStatus {
    switch (status) {
      case EventRegistrationStatus.pending:
        return 'Pending';
      case EventRegistrationStatus.approved:
        return 'Approved';
      case EventRegistrationStatus.rejected:
        return 'Rejected';
      case EventRegistrationStatus.confirmed:
        return 'Confirmed';
      case EventRegistrationStatus.completed:
        return 'Completed';
      case EventRegistrationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get formattedSubmissionDate {
    return '${submissionDate.day}/${submissionDate.month}/${submissionDate.year} ${submissionDate.hour}:${submissionDate.minute.toString().padLeft(2, '0')}';
  }
}
