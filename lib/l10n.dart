// App strings: Arabic (default) and English. No extra packages — a small
// hand-rolled table. Add new keys to BOTH classes.

enum AppLanguage { arabic, english }

abstract class Strings {
  // Navigation / titles
  String get brandSub;
  String get navDevices;
  String get navPreferences;
  String get navAbout;
  String devicesTitle(int count);
  String get preferencesTitle;
  String get aboutTitle;

  // Server status
  String runningStatus(int port, int count);
  String stoppedStatus(int count);
  String get startServer;
  String get stopServer;
  String serverRunningSnack(int count);
  String get serverStoppedSnack;
  String startFailed(String error);

  // Connect panel
  String get connectPhone;
  String get noAddresses;
  String get qrStartServerFirst;
  String get qrHint;

  // Devices panel
  String get connectedDevices;
  String get colDevice;
  String get colAddress;
  String get colStatus;
  String get statusConnected;
  String get statusLimited;
  String get noDevices;
  String get selectDeviceHint;
  String detailWaiting(String name, String address, int port);
  String detailStats(
      String name, String address, int port, int requests, double intervalMs);
  String detailLimited(String name, String address, int port, String reason);
  String get platformUnsupported;
  String get disconnectSelected;
  String get disconnectAll;

  // Rename
  String get rename;
  String get renameTitle;
  String get renameHint;
  String get save;
  String get clear;
  String get cancel;

  // Preferences
  String get inputMethod;
  String get gamepadMode;
  String get gamepadModeSub;
  String get keyboardMode;
  String get keyboardModeSub;
  String get connection;
  String get serverPort;
  String get portAutoHint;
  String get pointer;
  String get pointerSpeed;
  String get language;
  String get portRangeError;
  String get portChangedRestart;

  // About
  String get aboutHeading;
  String versionLabel(String version);
  String get aboutBody;
}

class ArabicStrings implements Strings {
  @override
  String get brandSub => 'مدير الأجهزة';
  @override
  String get navDevices => 'الأجهزة';
  @override
  String get navPreferences => 'الإعدادات';
  @override
  String get navAbout => 'حول التطبيق';
  @override
  String devicesTitle(int count) => count == 0 ? 'الأجهزة' : 'الأجهزة ($count)';
  @override
  String get preferencesTitle => 'الإعدادات';
  @override
  String get aboutTitle => 'حول التطبيق';

  String _count(int n) {
    if (n == 0) return 'لا أجهزة متصلة';
    if (n == 1) return 'جهاز واحد متصل';
    if (n == 2) return 'جهازان متصلان';
    if (n <= 10) return '$n أجهزة متصلة';
    return '$n جهازًا متصلًا';
  }

  @override
  String runningStatus(int port, int count) =>
      '●  يعمل  ·  المنفذ $port  ·  ${_count(count)}';
  @override
  String stoppedStatus(int count) => '○  متوقف  ·  ${_count(count)}';
  @override
  String get startServer => 'تشغيل الخادم';
  @override
  String get stopServer => 'إيقاف الخادم';
  @override
  String serverRunningSnack(int count) => 'الخادم يعمل — ${_count(count)}';
  @override
  String get serverStoppedSnack => 'الخادم متوقف';
  @override
  String startFailed(String error) => 'تعذّر التشغيل: $error';

  @override
  String get connectPhone => 'توصيل هاتف';
  @override
  String get noAddresses => 'لا توجد عناوين شبكة.';
  @override
  String get qrStartServerFirst => 'شغّل الخادم\nلعرض الرمز';
  @override
  String get qrHint =>
      'امسح الرمز أو أدخل IP والمنفذ في تطبيق الهاتف — كرر لكل هاتف.';

  @override
  String get connectedDevices => 'الأجهزة المتصلة';
  @override
  String get colDevice => 'الجهاز';
  @override
  String get colAddress => 'العنوان';
  @override
  String get colStatus => 'الحالة';
  @override
  String get statusConnected => 'متصل';
  @override
  String get statusLimited => 'محدود';
  @override
  String get noDevices => 'لا توجد أجهزة متصلة. شغّل الخادم وامسح الرمز.';
  @override
  String get selectDeviceHint => 'اختر جهازًا متصلًا لعرض تفاصيله.';
  @override
  String detailWaiting(String name, String address, int port) =>
      'الجهاز: $name\n\nالعنوان: $address : $port\n\nالحالة: متصل، بانتظار الإدخال…';
  @override
  String detailStats(String name, String address, int port, int requests,
          double intervalMs) =>
      'الجهاز: $name\n\nالعنوان: $address : $port\n\nالطلبات المعالجة: $requests\n\nمتوسط الفاصل بين الطلبات: ${intervalMs.toStringAsFixed(2)} مللي ثانية';
  @override
  String detailLimited(String name, String address, int port, String reason) =>
      'الجهاز: $name\n\nالعنوان: $address : $port\n\nالحالة: متصل لكن بدون جهاز افتراضي — $reason';
  @override
  String get platformUnsupported =>
      'وضع الإدخال هذا غير مدعوم على نظام التشغيل هذا بعد';
  @override
  String get disconnectSelected => 'قطع المحدد';
  @override
  String get disconnectAll => 'قطع الكل';

  @override
  String get rename => 'إعادة التسمية';
  @override
  String get renameTitle => 'إعادة تسمية الجهاز';
  @override
  String get renameHint => 'اسم الجهاز';
  @override
  String get save => 'حفظ';
  @override
  String get clear => 'مسح';
  @override
  String get cancel => 'إلغاء';

  @override
  String get inputMethod => 'طريقة الإدخال';
  @override
  String get gamepadMode => 'يد تحكم افتراضية';
  @override
  String get gamepadModeSub => 'يد تحكم افتراضية لكل هاتف';
  @override
  String get keyboardMode => 'محاكاة لوحة المفاتيح والفأرة';
  @override
  String get keyboardModeSub =>
      'التعيين الافتراضي (Enter وEsc وWASD والأسهم والنقر)';
  @override
  String get connection => 'الاتصال';
  @override
  String get serverPort => 'منفذ الخادم';
  @override
  String get portAutoHint => '0 = تلقائي';
  @override
  String get pointer => 'المؤشر';
  @override
  String get pointerSpeed => 'سرعة المؤشر';
  @override
  String get language => 'اللغة';
  @override
  String get portRangeError => 'يجب أن يكون المنفذ 0 (تلقائي) أو بين 1 و65535.';
  @override
  String get portChangedRestart => 'تم تغيير المنفذ — تتم إعادة تشغيل الخادم…';

  @override
  String get aboutHeading => 'منصة المتحكمات';
  @override
  String versionLabel(String version) => 'الإصدار: $version';
  @override
  String get aboutBody => 'استخدم هاتفك كيد تحكم للحاسوب.\n\n'
      'نافذة واحدة تدير كل الهواتف: توصيل سريع برمز QR، إعادة تسمية '
      'الأجهزة، ويد افتراضية لكل هاتف أو محاكاة لوحة المفاتيح والفأرة.\n\n'
      'مبنية على عمل kitswas في VirtualGamePad-PC (GPL-3.0).\n'
      'التفاصيل التقنية في docs/TECHNICAL.MD.';
}

class EnglishStrings implements Strings {
  @override
  String get brandSub => 'Device manager';
  @override
  String get navDevices => 'Devices';
  @override
  String get navPreferences => 'Preferences';
  @override
  String get navAbout => 'About';
  @override
  String devicesTitle(int count) => count == 0 ? 'Devices' : 'Devices ($count)';
  @override
  String get preferencesTitle => 'Preferences';
  @override
  String get aboutTitle => 'About';

  @override
  String runningStatus(int port, int count) =>
      '●  RUNNING  ·  Port $port  ·  $count connected';
  @override
  String stoppedStatus(int count) => '○  STOPPED  ·  $count connected';
  @override
  String get startServer => 'Start Server';
  @override
  String get stopServer => 'Stop Server';
  @override
  String serverRunningSnack(int count) =>
      'Server running — $count device(s) connected';
  @override
  String get serverStoppedSnack => 'Server stopped';
  @override
  String startFailed(String error) => 'Could not start: $error';

  @override
  String get connectPhone => 'Connect a phone';
  @override
  String get noAddresses => 'No network addresses found.';
  @override
  String get qrStartServerFirst => 'Start the server\nto show the code';
  @override
  String get qrHint =>
      'Scan the code or enter the IP and port in the phone app — repeat for every phone.';

  @override
  String get connectedDevices => 'Connected devices';
  @override
  String get colDevice => 'DEVICE';
  @override
  String get colAddress => 'ADDRESS';
  @override
  String get colStatus => 'STATUS';
  @override
  String get statusConnected => 'Connected';
  @override
  String get statusLimited => 'Limited';
  @override
  String get noDevices =>
      'No devices connected. Start the server and scan the code.';
  @override
  String get selectDeviceHint =>
      'Select a connected device to view its details.';
  @override
  String detailWaiting(String name, String address, int port) =>
      'Device: $name\n\nAddress: $address : $port\n\nStatus: connected, waiting for input…';
  @override
  String detailStats(String name, String address, int port, int requests,
          double intervalMs) =>
      'Device: $name\n\nAddress: $address : $port\n\nRequests handled: $requests\n\nAverage request interval: ${intervalMs.toStringAsFixed(2)} ms';
  @override
  String detailLimited(String name, String address, int port, String reason) =>
      'Device: $name\n\nAddress: $address : $port\n\nStatus: connected, but no virtual device — $reason';
  @override
  String get platformUnsupported =>
      'This input method is not supported on this desktop OS yet';
  @override
  String get disconnectSelected => 'Disconnect selected';
  @override
  String get disconnectAll => 'Disconnect all';

  @override
  String get rename => 'Rename';
  @override
  String get renameTitle => 'Rename device';
  @override
  String get renameHint => 'Device name';
  @override
  String get save => 'Save';
  @override
  String get clear => 'Clear';
  @override
  String get cancel => 'Cancel';

  @override
  String get inputMethod => 'Input execution method';
  @override
  String get gamepadMode => 'Virtual gamepad';
  @override
  String get gamepadModeSub => 'One virtual gamepad per phone';
  @override
  String get keyboardMode => 'Keyboard / mouse simulation';
  @override
  String get keyboardModeSub =>
      'Default mapping (Enter, Esc, WASD, arrows, clicks)';
  @override
  String get connection => 'Connection';
  @override
  String get serverPort => 'Server port';
  @override
  String get portAutoHint => '0 = auto';
  @override
  String get pointer => 'Pointer';
  @override
  String get pointerSpeed => 'Pointer speed';
  @override
  String get language => 'Language';
  @override
  String get portRangeError => 'Port must be 0 (auto) or 1–65535.';
  @override
  String get portChangedRestart => 'Port changed — restarting server…';

  @override
  String get aboutHeading => 'Minassat Al-Mutahakkamat';
  @override
  String versionLabel(String version) => 'Version: $version';
  @override
  String get aboutBody => 'Use your phone as a PC gamepad.\n\n'
      'One window manages every phone: quick QR pairing, device renaming, '
      'and a virtual gamepad per phone or keyboard/mouse simulation.\n\n'
      'Based on the work of kitswas in VirtualGamePad-PC (GPL-3.0).\n'
      'Technical details in docs/TECHNICAL.MD.';
}

Strings stringsFor(AppLanguage language) =>
    language == AppLanguage.arabic ? ArabicStrings() : EnglishStrings();
