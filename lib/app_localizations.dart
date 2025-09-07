import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // English translations
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'salaamAli': 'Salaam, Ali!',
      'overallProgress': 'Overall Progress',
      'dhikrGoal': 'Dhikr Goal',
      'khitmaGoal': 'Khitma Goal',
      'dhikrOutOf': '50 Dhikr out of 100',
      'juzzOutOf': '15 Juzz out of 30',
      'currentStreak': 'Current Streak',
      'yourCurrentStreak': 'Your Current Streak',
      'days': 'Days',
      'motivationalVerse': 'Motivational Verse',
      'verseText': 'Indeed, Allah is with those who fear Him and those who are doers of good.',
      'surahAnNahl': 'Surah An-Nahl',
      'home': 'Home',
      'dhikr': 'Dhikr',
      'khitma': 'Khitma',
      'groups': 'Groups',
      'khitmaGroups': 'Khitma Groups',
      'dhikrGroups': 'Dhikr Groups',
      'profile': 'Profile',
      'accountInfo': 'Account Info.',
      'accountDetails': 'Account Details',
      'editProfile': 'Edit Profile',
      'languageAndDisplay': 'Language & Display',
      'chooseLanguage': 'Choose Language',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'reminderPreference': 'Reminder Preference',
      'dhikrReminder': 'Dhikr Reminder',
      'reminderSettings': 'Reminder Settings',
      'groupManagement': 'Group Management',
'privacyAndNotification': 'Privacy & Notifications',
      'accountControl': 'Account Control',
      'accountDeletionRequest': 'Account Deletion Request',
      'logout': 'Logout',
      'logoutConfirmMessage': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'english': 'English',
      'arabic': 'العربية',
      'deleteAccount': 'Delete Account',
      'deleteAccountExplain': 'This action is permanent and cannot be undone. All your data will be erased.',
      'enterPassword': 'Enter your password to continue',
      'password': 'Password',
      'confirmDelete': 'Yes, delete my account',
      'continue': 'Continue',
      'finalWarning': 'Final Warning',
      'username': 'Username',
      'email': 'Email',
      'save': 'Save',
      'removePhoto': 'Remove photo',
      'changePhoto': 'Change photo',
      'camera': 'Camera',
      'gallery': 'Gallery',
'invalidUsername': 'Username can contain letters and spaces only (no numbers or special characters)',
'usernameRules': 'Letters and spaces only – no numbers or special characters',
      'invalidImageType': 'Invalid image type. Allowed: JPG, JPEG, PNG',
      'imageTooLarge': 'Image is too large. Maximum size is 2 MB',
      'avatarRemoved': 'Profile photo removed',
      'profileUpdated': 'Profile updated',
'memberSince': 'Member since',
      'pushNotifications': 'Push notifications',
      'showInAppNotifications': 'Show in-app notifications',
      'groupNotifications': 'Group notifications (Khitma & Dhikr)',
      'motivationalMessages': 'Motivational messages',
      'personalReminders': 'Personal reminders (daily wered & dhikr)',
    },
    'ar': {
      'salaamAli': 'السلام عليك يا علي!',
      'overallProgress': 'التقدم العام',
      'dhikrGoal': 'هدف الذكر',
      'khitmaGoal': 'هدف الختمة',
      'dhikrOutOf': '٥٠ ذكر من أصل ١٠٠',
      'juzzOutOf': '١٥ جزء من أصل ٣٠',
      'currentStreak': 'السلسلة الحالية',
      'yourCurrentStreak': 'سلسلتك الحالية',
      'days': 'أيام',
      'motivationalVerse': 'الآية التحفيزية',
      'verseText': 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوْا وَالَّذِينَ هُمْ مُحْسِنُونَ',
      'surahAnNahl': 'سورة النحل',
      'home': 'الرئيسية',
      'dhikr': 'الذكر',
      'khitma': 'الختمة',
      'groups': 'المجموعات',
      'khitmaGroups': 'مجموعات الختمة',
      'dhikrGroups': 'مجموعات الذكر',
      'profile': 'الملف الشخصي',
      'accountInfo': 'معلومات الحساب',
      'accountDetails': 'تفاصيل الحساب',
      'editProfile': 'تعديل الملف الشخصي',
      'languageAndDisplay': 'اللغة والعرض',
      'chooseLanguage': 'اختر اللغة',
      'lightMode': 'الوضع الفاتح',
      'darkMode': 'الوضع الداكن',
      'reminderPreference': 'تفضيلات التذكير',
      'dhikrReminder': 'تذكير الذكر',
      'reminderSettings': 'إعدادات التذكير',
      'groupManagement': 'إدارة المجموعات',
      'privacyAndNotification': 'الخصوصية والإشعارات',
      'accountControl': 'التحكم في الحساب',
      'accountDeletionRequest': 'طلب حذف الحساب',
      'logout': 'تسجيل الخروج',
      'logoutConfirmMessage': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'english': 'English',
      'arabic': 'العربية',
      'deleteAccount': 'حذف الحساب',
      'deleteAccountExplain': 'هذا الإجراء نهائي ولا يمكن التراجع عنه. سيتم حذف جميع بياناتك.',
      'enterPassword': 'أدخل كلمة المرور للمتابعة',
      'password': 'كلمة المرور',
      'confirmDelete': 'نعم، احذف حسابي',
      'continue': 'متابعة',
      'finalWarning': 'تحذير نهائي',
      'username': 'اسم المستخدم',
      'email': 'البريد الإلكتروني',
      'save': 'حفظ',
      'removePhoto': 'حذف الصورة',
      'changePhoto': 'تغيير الصورة',
      'camera': 'الكاميرا',
      'gallery': 'المعرض',
'invalidUsername': 'اسم المستخدم يجب أن يحتوي على حروف ومسافات فقط (بدون أرقام أو رموز)',
'usernameRules': 'مسموح: حروف ومسافات فقط — بدون أرقام أو رموز',
      'invalidImageType': 'نوع الصورة غير صالح. المسموح: JPG, JPEG, PNG',
      'imageTooLarge': 'الصورة كبيرة جدًا. الحد الأقصى 2 ميجابايت',
      'avatarRemoved': 'تم حذف صورة الملف الشخصي',
      'profileUpdated': 'تم تحديث الملف الشخصي',
'memberSince': 'عضو منذ',
      'pushNotifications': 'إشعارات الدفع',
      'showInAppNotifications': 'عرض الإشعارات داخل التطبيق',
      'groupNotifications': 'إشعارات المجموعة (الختمة والذكر)',
      'motivationalMessages': 'رسائل تحفيزية',
      'personalReminders': 'تذكيرات شخصية (الورد والذكر اليومي)',
    },
  };

  String get salaamAli => _localizedValues[locale.languageCode]?['salaamAli'] ?? 'Salaam, Ali!';
  String get overallProgress => _localizedValues[locale.languageCode]?['overallProgress'] ?? 'Overall Progress';
  String get dhikrGoal => _localizedValues[locale.languageCode]?['dhikrGoal'] ?? 'Dhikr Goal';
  String get khitmaGoal => _localizedValues[locale.languageCode]?['khitmaGoal'] ?? 'Khitma Goal';
  String get dhikrOutOf => _localizedValues[locale.languageCode]?['dhikrOutOf'] ?? '50 Dhikr out of 100';
  String get juzzOutOf => _localizedValues[locale.languageCode]?['juzzOutOf'] ?? '15 Juzz out of 30';
  String get currentStreak => _localizedValues[locale.languageCode]?['currentStreak'] ?? 'Current Streak';
  String get yourCurrentStreak => _localizedValues[locale.languageCode]?['yourCurrentStreak'] ?? 'Your Current Streak';
  String get days => _localizedValues[locale.languageCode]?['days'] ?? '5 Days';
  String get motivationalVerse => _localizedValues[locale.languageCode]?['motivationalVerse'] ?? 'Motivational Verse';
  String get verseText => _localizedValues[locale.languageCode]?['verseText'] ?? 'Indeed, Allah is with those who fear Him and those who are doers of good.';
  String get surahAnNahl => _localizedValues[locale.languageCode]?['surahAnNahl'] ?? 'Surah An-Nahl';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get dhikr => _localizedValues[locale.languageCode]?['dhikr'] ?? 'Dhikr';
  String get khitma => _localizedValues[locale.languageCode]?['khitma'] ?? 'Khitma';
  String get groups => _localizedValues[locale.languageCode]?['groups'] ?? 'Groups';
  String get khitmaGroups => _localizedValues[locale.languageCode]?['khitmaGroups'] ?? 'Khitma Groups';
  String get dhikrGroups => _localizedValues[locale.languageCode]?['dhikrGroups'] ?? 'Dhikr Groups';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get accountInfo => _localizedValues[locale.languageCode]?['accountInfo'] ?? 'Account Info.';
  String get accountDetails => _localizedValues[locale.languageCode]?['accountDetails'] ?? 'Account Details';
  String get editProfile => _localizedValues[locale.languageCode]?['editProfile'] ?? 'Edit Profile';
  String get languageAndDisplay => _localizedValues[locale.languageCode]?['languageAndDisplay'] ?? 'Language & Display';
  String get chooseLanguage => _localizedValues[locale.languageCode]?['chooseLanguage'] ?? 'Choose Language';
  String get lightMode => _localizedValues[locale.languageCode]?['lightMode'] ?? 'Light Mode';
  String get darkMode => _localizedValues[locale.languageCode]?['darkMode'] ?? 'Dark Mode';
  String get reminderPreference => _localizedValues[locale.languageCode]?['reminderPreference'] ?? 'Reminder Preference';
  String get dhikrReminder => _localizedValues[locale.languageCode]?['dhikrReminder'] ?? 'Dhikr Reminder';
  String get reminderSettings => _localizedValues[locale.languageCode]?['reminderSettings'] ?? 'Reminder Settings';
  String get groupManagement => _localizedValues[locale.languageCode]?['groupManagement'] ?? 'Group Management';
  String get privacyAndNotification => _localizedValues[locale.languageCode]?['privacyAndNotification'] ?? 'Privacy & Notification';
  String get accountControl => _localizedValues[locale.languageCode]?['accountControl'] ?? 'Account Control';
  String get accountDeletionRequest => _localizedValues[locale.languageCode]?['accountDeletionRequest'] ?? 'Account Deletion Request';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get logoutConfirmMessage => _localizedValues[locale.languageCode]?['logoutConfirmMessage'] ?? 'Are you sure you want to log out?';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get arabic => _localizedValues[locale.languageCode]?['arabic'] ?? 'العربية';
  String get deleteAccount => _localizedValues[locale.languageCode]?['deleteAccount'] ?? 'Delete Account';
  String get deleteAccountExplain => _localizedValues[locale.languageCode]?['deleteAccountExplain'] ?? 'This action is permanent and cannot be undone. All your data will be erased.';
  String get enterPassword => _localizedValues[locale.languageCode]?['enterPassword'] ?? 'Enter your password to continue';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get confirmDelete => _localizedValues[locale.languageCode]?['confirmDelete'] ?? 'Yes, delete my account';
  String get continueLabel => _localizedValues[locale.languageCode]?['continue'] ?? 'Continue';
  String get finalWarning => _localizedValues[locale.languageCode]?['finalWarning'] ?? 'Final Warning';
  String get username => _localizedValues[locale.languageCode]?['username'] ?? 'Username';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get removePhoto => _localizedValues[locale.languageCode]?['removePhoto'] ?? 'Remove photo';
  String get changePhoto => _localizedValues[locale.languageCode]?['changePhoto'] ?? 'Change photo';
  String get camera => _localizedValues[locale.languageCode]?['camera'] ?? 'Camera';
  String get gallery => _localizedValues[locale.languageCode]?['gallery'] ?? 'Gallery';
  String get invalidUsername => _localizedValues[locale.languageCode]?['invalidUsername'] ?? 'Username can contain letters and spaces only (no numbers or special characters)';
  String get usernameRules => _localizedValues[locale.languageCode]?['usernameRules'] ?? 'Letters and spaces only – no numbers or special characters';
  String get invalidImageType => _localizedValues[locale.languageCode]?['invalidImageType'] ?? 'Invalid image type. Allowed: JPG, JPEG, PNG';
  String get imageTooLarge => _localizedValues[locale.languageCode]?['imageTooLarge'] ?? 'Image is too large. Maximum size is 2 MB';
  String get avatarRemoved => _localizedValues[locale.languageCode]?['avatarRemoved'] ?? 'Profile photo removed';
  String get profileUpdated => _localizedValues[locale.languageCode]?['profileUpdated'] ?? 'Profile updated';
  String get memberSince => _localizedValues[locale.languageCode]?['memberSince'] ?? 'Member since';

  // Privacy & Notifications additions
  String get pushNotifications => _localizedValues[locale.languageCode]?['pushNotifications'] ?? 'Push notifications';
  String get showInAppNotifications => _localizedValues[locale.languageCode]?['showInAppNotifications'] ?? 'Show in-app notifications';
  String get groupNotifications => _localizedValues[locale.languageCode]?['groupNotifications'] ?? 'Group notifications (Khitma & Dhikr)';
  String get motivationalMessages => _localizedValues[locale.languageCode]?['motivationalMessages'] ?? 'Motivational messages';
  String get personalReminders => _localizedValues[locale.languageCode]?['personalReminders'] ?? 'Personal reminders (daily wered & dhikr)';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 