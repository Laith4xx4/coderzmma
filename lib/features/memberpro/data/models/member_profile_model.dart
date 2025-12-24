class MemberProfileModel {
  final int id;
  // تحويل الحقول التي قد تأتي فارغة من السيرفر إلى اختيارية (?) أو وضع قيم افتراضية
  final String userId;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalInfo;
  final DateTime joinDate;
  final int bookingsCount;
  final int attendanceCount;
  final int feedbacksGivenCount;
  final int progressRecordsCount;

  MemberProfileModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.firstName,
    this.lastName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalInfo,
    required this.joinDate,
    required this.bookingsCount,
    required this.attendanceCount,
    required this.feedbacksGivenCount,
    required this.progressRecordsCount,
  });

  factory MemberProfileModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileModel(
      id: json['id'] ?? 0,
      // استخدام معامل "?? ''" يضمن أنه إذا كانت القيمة null سيتم وضع نص فارغ بدلاً من تعطل التطبيق
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      firstName: json['firstName'],
      lastName: json['lastName'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      medicalInfo: json['medicalInfo'],
      // معالجة التاريخ لضمان عدم حدوث خطأ عند Parse إذا كان فارغاً
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      // التأكد من أن الأرقام ليست null
      bookingsCount: json['bookingsCount'] ?? 0,
      attendanceCount: json['attendanceCount'] ?? 0,
      feedbacksGivenCount: json['feedbacksGivenCount'] ?? 0,
      progressRecordsCount: json['progressRecordsCount'] ?? 0,
    );
  }
}