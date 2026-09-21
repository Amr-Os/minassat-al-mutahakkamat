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
  String get singleWindowHint;
  String get introSecond;
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
  String detailLimited(
      String name, String address, int port, String reason);
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
  String devicesTitle(int count) =>
      count == 0 ? 'الأجهزة' : 'الأجهزة ($count)';
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
  String serverRunningSnack(int count) =>
      'الخادم يعمل — ${_count(count)}';
  @override
  String get serverStoppedSnack => 'الخادم متوقف';
  @override
  String get singleWindowHint =>
      'مدير بنافذة واحدة — صِل أي عدد من الهواتف';
  @override
  String get introSecond =>
      'كل هاتف يحصل على يد تحكم افتراضية خاصة به (Virtual Gamepad PC وVirtual Gamepad PC 2 وهكذا).';  @override
  String startFailed(String error) => 'تعذّر التشغيل: $error';

  @override
  String get connectPhone => 'توصيل هاتف';
  @override
  String get noAddresses => 'لا توجد عناوين شبكة.';
  @override
  String get qrStartServerFirst => 'شغّل الخادم\nلعرض الرمز';
  @override
  String get qrHint =>
      'امسح رمز QR أو أدخل عنوان IP والمنفذ في تطبيق الهاتف. كرر ذلك لكل هاتف — لا حاجة لنسخة ثانية من التطبيق.';

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
  String get noDevices =>
      'لا توجد أجهزة متصلة. شغّل الخادم وامسح الرمز.';
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
  String detailLimited(
          String name, String address, int port, String reason) =>
      'الجهاز: $name\n\nالعنوان: $address : $port\n\nالحالة: متصل لكن بدون جهاز افتراضي — $reason';
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
  String get portRangeError =>
      'يجب أن يكون المنفذ 0 (تلقائي) أو بين 1 و65535.';
  @override
  String get portChangedRestart =>
      'تم تغيير المنفذ — تتم إعادة تشغيل الخادم…';

  @override
  String get aboutHeading => 'خادم يد التحكم الافتراضية';
  @override
  String versionLabel(String version) => 'الإصدار: $version';
  @override
  String get aboutBody =>
      'جزء من مشروع يد التحكم الافتراضية\n'
      '(https://kitswas.github.io/VirtualGamePad).\n\n'
      'الكود المصدري: https://github.com/kitswas/VirtualGamePad-PC\n\n'
      'البروتوكول: حزم GamepadReading بترميز Colfer الثنائي عبر TCP. '
      'الحقن في لينكس عبر uinput/libevdev — لا حاجة لأي تعريفات.\n\n'
      'كل الاتصالات محلية (Wi-Fi/LAN). لا إعلانات ولا تتبع.';
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
  String devicesTitle(int count) =>
      count == 0 ? 'Devices' : 'Devices ($count)';
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
  String get singleWindowHint =>
      'Single-window manager — connect any number of phones';
  @override
  String get introSecond =>
      'Each phone gets its own virtual gamepad device (Virtual Gamepad PC, Virtual Gamepad PC 2, …).';
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
      'Scan the QR code or type the IP and port into the mobile app. Repeat for every phone — no second app instance needed.';

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
  String detailLimited(
          String name, String address, int port, String reason) =>
      'Device: $name\n\nAddress: $address : $port\n\nStatus: connected, but no virtual device — $reason';
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
  String get portChangedRestart =>
      'Port changed — restarting server…';

  @override
  String get aboutHeading => 'Virtual Gamepad PC Server';
  @override
  String versionLabel(String version) => 'Version: $version';
  @override
  String get aboutBody =>
      'Part of the Virtual Gamepad project\n'
      '(https://kitswas.github.io/VirtualGamePad).\n\n'
      'Source code: https://github.com/kitswas/VirtualGamePad-PC\n\n'
      'Protocol: Colfer-binary GamepadReading packets over TCP. '
      'Linux input via uinput/libevdev — no drivers needed.\n\n'
      'Local traffic only. No ads, tracking, or telemetry.';
}

Strings stringsFor(AppLanguage language) =>
    language == AppLanguage.arabic ? ArabicStrings() : EnglishStrings();
