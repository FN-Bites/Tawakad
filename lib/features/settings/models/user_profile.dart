// 📦 user_profile.dart — نموذج بيانات المستخدم من Firestore

class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? status;
  final String? takesMedication;
  final String? medicationNotes;

  const UserProfile({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.gender,
    this.status,
    this.takesMedication,
    this.medicationNotes,
  });

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? 'اسم المستخدم' : full;
  }

  factory UserProfile.fromFirestore({
    required String uid,
    required String email,
    Map<String, dynamic>? data,
  }) {
    final answers = (data?['answers'] as List<dynamic>?)?.cast<String>() ?? [];
    return UserProfile(
      uid: uid,
      email: email,
      firstName: answers.isNotEmpty ? answers[0] : '',
      lastName: answers.length > 1 ? answers[1] : '',
      gender: answers.length > 2 && answers[2].isNotEmpty ? answers[2] : null,
      status: answers.length > 3 && answers[3].isNotEmpty ? answers[3] : null,
      takesMedication:
          answers.length > 4 && answers[4].isNotEmpty ? answers[4] : null,
      medicationNotes: data?['medicationNotes'] as String?,
    );
  }

  List<String> toAnswers() => [
        firstName,
        lastName,
        gender ?? '',
        status ?? '',
        takesMedication ?? '',
      ];

  UserProfile copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? status,
    String? takesMedication,
    String? medicationNotes,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      takesMedication: takesMedication ?? this.takesMedication,
      medicationNotes: medicationNotes ?? this.medicationNotes,
    );
  }
}
