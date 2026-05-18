// 🏷️ profile_labels.dart — تسميات عرض (جنس، حالة، لغة)

String profileGenderLabel(String? value) {
  switch (value) {
    case 'female':
      return 'أنثى';
    case 'male':
      return 'ذكر';
    default:
      return 'غير محدد';
  }
}

String profileStatusLabel(String? value) {
  switch (value) {
    case 'student':
      return 'طالب';
    case 'employee':
      return 'موظف';
    case 'free':
      return 'متفرغ';
    case 'other':
      return 'أخرى';
    default:
      return 'غير محدد';
  }
}

/// اللغة المفعّلة حالياً في التطبيق.
const String profileActiveLanguageLabel = 'العربية';

/// الإنجليزية غير متاحة بعد — تُعرض بالرمادي في الإعدادات.
const String profileEnglishComingSoonLabel = 'English — قريباً';
