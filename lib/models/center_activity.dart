class CenterActivity {
  final int id;
  final String activityName;
  final String startAt;
  final String endAt;
  final String activityTypeName;
  final String activityStatusName;
  final String? activityShortDescription;
  final String? activityDescription;
  final String centerName;

  CenterActivity({
    required this.id,
    required this.activityName,
    required this.startAt,
    required this.endAt,
    required this.activityTypeName,
    required this.activityStatusName,
    this.activityShortDescription,
    this.activityDescription,
    required this.centerName,
  });

  factory CenterActivity.fromJson(Map<String, dynamic> json) {
    return CenterActivity(
      id: json['id'],
      activityName: json['activityName'],
      startAt: json['startAt'],
      endAt: json['endAt'],
      activityTypeName: json['activityTypeName'],
      activityStatusName: json['activityStatusName'],
      activityShortDescription: json['activityShortDescription'],
      activityDescription: json['activityDescription'],
      centerName: json['centerName'],
    );
  }
}
