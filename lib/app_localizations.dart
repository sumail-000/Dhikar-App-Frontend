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
      'privacyAndNotification': 'Notification Setting',
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
      'pushNotifications': 'All Notifications',
      'showInAppNotifications': 'Show in-app notifications',
      'groupNotifications': 'Group notifications (Khitma & Dhikr)',
      'motivationalMessages': 'Motivational messages',
'personalReminders': 'Personal reminders (daily wered & dhikr)',

      // Generic statuses
      'loading': 'Loading...',
      'errorLoading': 'Error loading',
      'errorLoadingDhikr': 'Error loading dhikr',
      'outOfWord': 'out of',

      // Home / Personal Khitma
      'personalKhitma': 'Personal Khitma',
      'errorLoadingData': 'Error loading data',
      'tryAgain': 'Try Again',
      'noActiveKhitma': 'No active khitma',
      'startNewKhitma': 'Start a new khitma to continue',
      'pageShort': 'Page',
      'juzShort': 'Juz',
      'lastRead': 'Last read',
      'continueReading': 'Continue Reading',

      // Notifications
      'notifications': 'Notifications',
      'markAllRead': 'Mark all read',
      'individual': 'Individual',
      'group': 'Group',
'motivational': 'Motivational',
      'noNotifications': 'No available notifications',
      'notificationsAppearHere': 'Notifications will appear here when available',
'notificationSettings': 'Notification Settings',
      'groupInfoTitle': 'Group Info',
      'membersList': 'Members List',
      'noMemberAssignments': 'No member assignments found',
      'open': 'Open',
      'invite': 'Invite',
      'copy': 'Copy',
      'share': 'Share',
      'delete': 'Delete',
      'deleteGroupQuestion': 'Delete group?',
      'deleteGroupWarning': 'This will delete the group, its assignments and invites. This action cannot be undone.',
      'inviteMembers': 'Invite members',
      'inviteError': 'Invite error',
      'members': 'Members',
      'untitledGroup': 'Untitled Group',
      'public': 'Public',
      'private': 'Private',
      'unassigned': 'Unassigned',
      'quranCircle': "The Qur'an Circle",
      'loadingError': 'Loading Error',
      'goBack': 'Go Back',
      'backToHome': 'Back to Home',
      'groupKhitma': 'Group Khitma',
      'noContentToDisplay': 'No content to display',
      'groupKhitmaProgressSaved': 'Group khitma progress saved successfully!',
      'khitmaProgressSaved': 'Khitma progress saved successfully!',
      'completeWord': 'complete',
      'changeSurah': 'Change Surah',
      'saveProgress': 'Save Progress',
      'failedToSaveProgress': 'Failed to save progress',
      'failedToSaveGroupProgress': 'Failed to save group progress',
      'deleteFailed': 'Delete failed',
      'groupDeleted': 'Group deleted',
      'completed': 'Completed',
      'inProgress': 'In Progress',
'notStarted': 'Not Started',
      'dailyWered': 'Daily Wered',
      'dailyWeredSubtitle': 'Engage your heart in the remembrance of Allah. Select a Surah to begin your spiritual journey and peace.',
      'chooseSurah': 'Choose surah',
      'pages': 'pages',

      // Auth / Onboarding
      'login': 'Login',
      'loginTitle': 'Login',
      'loginSubtitle': 'Welcome back. Continue your path of remembrance, reflection, and worship with ease.',
      'signup': 'Sign Up',
      'signupTitle': 'Sign Up',
      'signupSubtitle': 'Join to start your spiritual journey. Track your Khitma, Dhikr and more.',
      'forgotPassword': 'Forgot password?',
      'enterEmailPassword': 'Please enter email and password',
      'enterValidEmailPassword8': 'Please enter a valid email and a password of at least 8 characters',
      'loginFailed': 'Login failed',
      'unexpectedServerResponse': 'Unexpected server response',
      'loggedInSuccessfully': 'Logged in successfully',
      'networkErrorTryLater': 'Network error. Please try again later.',
      'signUpFailed': 'Sign up failed',
      'accountCreatedSuccessfully': 'Account created successfully',
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
      'privacyAndNotification': 'إعدادات الإشعارات',
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
      'pushNotifications': 'جميع الإشعارات',
      'showInAppNotifications': 'عرض الإشعارات داخل التطبيق',
      'groupNotifications': 'إشعارات المجموعة (الختمة والذكر)',
      'motivationalMessages': 'رسائل تحفيزية',
'personalReminders': 'تذكيرات شخصية (الورد والذكر اليومي)',

      // Generic statuses
      'loading': 'جارٍ التحميل...',
      'errorLoading': 'خطأ في التحميل',
      'errorLoadingDhikr': 'خطأ في تحميل الذكر',
      'outOfWord': 'من أصل',

      // Home / Personal Khitma
      'personalKhitma': 'ختمتي الشخصية',
      'errorLoadingData': 'خطأ في تحميل البيانات',
      'tryAgain': 'إعادة المحاولة',
      'noActiveKhitma': 'لا توجد ختمة نشطة',
      'startNewKhitma': 'ابدأ ختمة جديدة للمتابعة',
      'pageShort': 'الصفحة',
      'juzShort': 'الجزء',
      'lastRead': 'آخر قراءة',
      'continueReading': 'متابعة القراءة',

      // Notifications
      'notifications': 'الإشعارات',
      'markAllRead': 'تحديد الكل كمقروء',
      'individual': 'فردي',
      'group': 'مجموعة',
'motivational': 'تحفيزي',
      'noNotifications': 'لا توجد إشعارات متاحة',
      'notificationsAppearHere': 'ستظهر الإشعارات هنا عند توفرها',
'notificationSettings': 'إعدادات الإشعارات',
      'groupInfoTitle': 'معلومات المجموعة',
      'membersList': 'قائمة الأعضاء',
      'noMemberAssignments': 'لا توجد تعيينات للأعضاء',
      'open': 'فتح',
      'invite': 'دعوة',
      'copy': 'نسخ',
      'share': 'مشاركة',
      'delete': 'حذف',
      'deleteGroupQuestion': 'حذف المجموعة؟',
      'deleteGroupWarning': 'سيتم حذف المجموعة وجميع التعيينات والدعوات. لا يمكن التراجع.',
      'inviteMembers': 'دعوة الأعضاء',
      'inviteError': 'خطأ الدعوة',
      'members': 'الأعضاء',
      'untitledGroup': 'مجموعة بدون اسم',
      'public': 'عام',
      'private': 'خاص',
      'unassigned': 'غير مُعين',
      'quranCircle': 'دائرة القرآن',
      'loadingError': 'خطأ في التحميل',
      'goBack': 'العودة',
      'backToHome': 'العودة للرئيسية',
      'groupKhitma': 'الختمة الجماعية',
      'noContentToDisplay': 'لا يوجد محتوى للعرض',
      'groupKhitmaProgressSaved': 'تم حفظ تقدم الختمة الجماعية بنجاح!',
      'khitmaProgressSaved': 'تم حفظ تقدم الختمة بنجاح!',
      'completeWord': 'مكتمل',
      'changeSurah': 'تغيير السورة',
      'saveProgress': 'حفظ التقدم',
      'failedToSaveProgress': 'فشل حفظ التقدم',
      'failedToSaveGroupProgress': 'فشل حفظ تقدم الختمة الجماعية',
      'deleteFailed': 'فشل الحذف',
      'groupDeleted': 'تم حذف المجموعة',
      'completed': 'مكتمل',
      'inProgress': 'قيد التقدم',
'notStarted': 'لم يبدأ',
      'dailyWered': 'الورد اليومي',
      'dailyWeredSubtitle': 'اشغل قلبك بذكر الله. اختر سورة لتبدأ رحلتك الروحية والسلام.',
      'chooseSurah': 'اختر السورة',
      'pages': 'صفحة',

      // Auth / Onboarding
      'login': 'تسجيل الدخول',
      'loginTitle': 'تسجيل الدخول',
      'loginSubtitle': 'مرحبًا بعودتك. واصل طريقك في الذكر والتأمل والعبادة بسهولة.',
      'signup': 'إنشاء حساب',
      'signupTitle': 'إنشاء حساب',
      'signupSubtitle': 'انضم لبدء رحلتك الروحية. تتبع ختمتك وذكرك والمزيد.',
      'forgotPassword': 'هل نسيت كلمة المرور؟',
      'enterEmailPassword': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      'enterValidEmailPassword8': 'يرجى إدخال بريد إلكتروني صحيح وكلمة مرور لا تقل عن 8 أحرف',
      'loginFailed': 'فشل تسجيل الدخول',
      'unexpectedServerResponse': 'استجابة غير متوقعة من الخادم',
      'loggedInSuccessfully': 'تم تسجيل الدخول بنجاح',
      'networkErrorTryLater': 'خطأ في الشبكة. يرجى المحاولة لاحقًا.',
      'signUpFailed': 'فشل إنشاء الحساب',
      'accountCreatedSuccessfully': 'تم إنشاء الحساب بنجاح',
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

  // Generic statuses
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get errorLoading => _localizedValues[locale.languageCode]?['errorLoading'] ?? 'Error loading';
  String get errorLoadingDhikr => _localizedValues[locale.languageCode]?['errorLoadingDhikr'] ?? 'Error loading dhikr';
  String get outOfWord => _localizedValues[locale.languageCode]?['outOfWord'] ?? 'out of';

  // Daily Wered
  String get dailyWered => _localizedValues[locale.languageCode]?['dailyWered'] ?? 'Daily Wered';
  String get dailyWeredSubtitle => _localizedValues[locale.languageCode]?['dailyWeredSubtitle'] ?? 'Engage your heart in the remembrance of Allah. Select a Surah to begin your spiritual journey and peace.';
  String get chooseSurah => _localizedValues[locale.languageCode]?['chooseSurah'] ?? 'Choose surah';
  String get pages => _localizedValues[locale.languageCode]?['pages'] ?? 'pages';

  // Group / Info / Management
  String get groupInfoTitle => _localizedValues[locale.languageCode]?['groupInfoTitle'] ?? 'Group Info';
  String get membersList => _localizedValues[locale.languageCode]?['membersList'] ?? 'Members List';
  String get noMemberAssignments => _localizedValues[locale.languageCode]?['noMemberAssignments'] ?? 'No member assignments found';
  String get open => _localizedValues[locale.languageCode]?['open'] ?? 'Open';
  String get invite => _localizedValues[locale.languageCode]?['invite'] ?? 'Invite';
  String get copy => _localizedValues[locale.languageCode]?['copy'] ?? 'Copy';
  String get share => _localizedValues[locale.languageCode]?['share'] ?? 'Share';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get deleteGroupQuestion => _localizedValues[locale.languageCode]?['deleteGroupQuestion'] ?? 'Delete group?';
  String get deleteGroupWarning => _localizedValues[locale.languageCode]?['deleteGroupWarning'] ?? 'This will delete the group, its assignments and invites. This action cannot be undone.';
  String get inviteMembers => _localizedValues[locale.languageCode]?['inviteMembers'] ?? 'Invite members';
  String get inviteError => _localizedValues[locale.languageCode]?['inviteError'] ?? 'Invite error';
  String get members => _localizedValues[locale.languageCode]?['members'] ?? 'Members';
  String get untitledGroup => _localizedValues[locale.languageCode]?['untitledGroup'] ?? 'Untitled Group';

  // Home / Personal Khitma
  String get personalKhitma => _localizedValues[locale.languageCode]?['personalKhitma'] ?? 'Personal Khitma';
  String get errorLoadingData => _localizedValues[locale.languageCode]?['errorLoadingData'] ?? 'Error loading data';
  String get tryAgain => _localizedValues[locale.languageCode]?['tryAgain'] ?? 'Try Again';
  String get noActiveKhitma => _localizedValues[locale.languageCode]?['noActiveKhitma'] ?? 'No active khitma';
  String get startNewKhitma => _localizedValues[locale.languageCode]?['startNewKhitma'] ?? 'Start a new khitma to continue';
  String get pageShort => _localizedValues[locale.languageCode]?['pageShort'] ?? 'Page';
  String get juzShort => _localizedValues[locale.languageCode]?['juzShort'] ?? 'Juz';
  String get lastRead => _localizedValues[locale.languageCode]?['lastRead'] ?? 'Last read';
  String get continueReading => _localizedValues[locale.languageCode]?['continueReading'] ?? 'Continue Reading';

  // Notifications
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  String get markAllRead => _localizedValues[locale.languageCode]?['markAllRead'] ?? 'Mark all read';
  String get individual => _localizedValues[locale.languageCode]?['individual'] ?? 'Individual';
  String get group => _localizedValues[locale.languageCode]?['group'] ?? 'Group';
  String get motivational => _localizedValues[locale.languageCode]?['motivational'] ?? 'Motivational';
  String get noNotifications => _localizedValues[locale.languageCode]?['noNotifications'] ?? 'No available notifications';
  String get notificationsAppearHere => _localizedValues[locale.languageCode]?['notificationsAppearHere'] ?? 'Notifications will appear here when available';
  String get notificationSettings => _localizedValues[locale.languageCode]?['notificationSettings'] ?? 'Notification Settings';
  String get public => _localizedValues[locale.languageCode]?['public'] ?? 'Public';
  String get private => _localizedValues[locale.languageCode]?['private'] ?? 'Private';
  String get unassigned => _localizedValues[locale.languageCode]?['unassigned'] ?? 'Unassigned';
  String get quranCircle => _localizedValues[locale.languageCode]?['quranCircle'] ?? "The Qur'an Circle";
  String get loadingError => _localizedValues[locale.languageCode]?['loadingError'] ?? 'Loading Error';
  String get goBack => _localizedValues[locale.languageCode]?['goBack'] ?? 'Go Back';
  String get backToHome => _localizedValues[locale.languageCode]?['backToHome'] ?? 'Back to Home';
  String get groupKhitma => _localizedValues[locale.languageCode]?['groupKhitma'] ?? 'Group Khitma';
  String get noContentToDisplay => _localizedValues[locale.languageCode]?['noContentToDisplay'] ?? 'No content to display';
  String get groupKhitmaProgressSaved => _localizedValues[locale.languageCode]?['groupKhitmaProgressSaved'] ?? 'Group khitma progress saved successfully!';
  String get khitmaProgressSaved => _localizedValues[locale.languageCode]?['khitmaProgressSaved'] ?? 'Khitma progress saved successfully!';
  String get completeWord => _localizedValues[locale.languageCode]?['completeWord'] ?? 'complete';
  String get changeSurah => _localizedValues[locale.languageCode]?['changeSurah'] ?? 'Change Surah';
  String get saveProgress => _localizedValues[locale.languageCode]?['saveProgress'] ?? 'Save Progress';
  String get failedToSaveProgress => _localizedValues[locale.languageCode]?['failedToSaveProgress'] ?? 'Failed to save progress';
  String get failedToSaveGroupProgress => _localizedValues[locale.languageCode]?['failedToSaveGroupProgress'] ?? 'Failed to save group progress';
  String get deleteFailed => _localizedValues[locale.languageCode]?['deleteFailed'] ?? 'Delete failed';
  String get groupDeleted => _localizedValues[locale.languageCode]?['groupDeleted'] ?? 'Group deleted';
  String get completed => _localizedValues[locale.languageCode]?['completed'] ?? 'Completed';
  String get inProgress => _localizedValues[locale.languageCode]?['inProgress'] ?? 'In Progress';
  String get notStarted => _localizedValues[locale.languageCode]?['notStarted'] ?? 'Not Started';

  // Auth / Onboarding getters
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get loginTitle => _localizedValues[locale.languageCode]?['loginTitle'] ?? 'Login';
  String get loginSubtitle => _localizedValues[locale.languageCode]?['loginSubtitle'] ?? 'Welcome back. Continue your path of remembrance, reflection, and worship with ease.';
  String get signup => _localizedValues[locale.languageCode]?['signup'] ?? 'Sign Up';
  String get signupTitle => _localizedValues[locale.languageCode]?['signupTitle'] ?? 'Sign Up';
  String get signupSubtitle => _localizedValues[locale.languageCode]?['signupSubtitle'] ?? 'Join to start your spiritual journey. Track your Khitma, Dhikr and more.';
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgotPassword'] ?? 'Forgot password?';
  String get enterEmailPassword => _localizedValues[locale.languageCode]?['enterEmailPassword'] ?? 'Please enter email and password';
  String get enterValidEmailPassword8 => _localizedValues[locale.languageCode]?['enterValidEmailPassword8'] ?? 'Please enter a valid email and a password of at least 8 characters';
  String get loginFailed => _localizedValues[locale.languageCode]?['loginFailed'] ?? 'Login failed';
  String get unexpectedServerResponse => _localizedValues[locale.languageCode]?['unexpectedServerResponse'] ?? 'Unexpected server response';
  String get loggedInSuccessfully => _localizedValues[locale.languageCode]?['loggedInSuccessfully'] ?? 'Logged in successfully';
  String get networkErrorTryLater => _localizedValues[locale.languageCode]?['networkErrorTryLater'] ?? 'Network error. Please try again later.';
  String get signUpFailed => _localizedValues[locale.languageCode]?['signUpFailed'] ?? 'Sign up failed';
  String get accountCreatedSuccessfully => _localizedValues[locale.languageCode]?['accountCreatedSuccessfully'] ?? 'Account created successfully';
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
