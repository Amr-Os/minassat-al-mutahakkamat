# خادم يد التحكم الافتراضية (VirtualGamePad PC)

[![GitHub Downloads](https://img.shields.io/github/downloads/kitswas/VirtualGamePad-PC/total)](https://github.com/kitswas/VirtualGamePad-PC/releases/latest)

> [!IMPORTANT]
>
> - للتنزيل والاستخدام والأسئلة الشائعة، زر [الموقع الرئيسي للمشروع](https://kitswas.github.io/VirtualGamePad/).
> - هذا الملف مخصص للتوثيق التقني للخادم.

## الشكر والفضل

هذا المشروع مبني على مشروع **[VirtualGamePad-PC](https://github.com/kitswas/VirtualGamePad-PC)**
للمطور **kitswas** — بروتوكول الاتصال (Colfer)، وفكرة التطبيق، والتعيينات
الافتراضية كلها من عمله الأصلي. هذه النسخة إعادة كتابة بلغة Flutter/Dart
لمنصة لينكس، وهي — مثل الأصل — مرخّصة تحت
**[GPL-3.0](LICENCE.TXT)**. جميع الحقوق الأصلية محفوظة لأصحابها.

## تاريخ تطوير الخادم

1. بدأ الخادم مكتوبًا بلغة C++.
2. ثم أُعيدت كتابته بلغة Rust ثم C# (WinUI 3).
3. ثم بلغة C++ مع Qt6، وأُضيف دعم لينكس.
4. **ثم أُعيدت كتابته بلغة Flutter (Dart)**: نافذة واحدة تدير كل
   الهواتف المتصلة، والحقن عبر `uinput`/`libevdev` باستخدام Dart FFI —
   ويعمل على أجهزة الحاسوب المكتبية (لينكس أولًا، وبقية الأنظمة لاحقًا).

## كيف يعمل

> [!NOTE]
> **اختيار التصميم:** [Colfer](https://github.com/pascaldekloe/colfer) بدل Protocol Buffers،
> للسرعة والبساطة.

1. **الاتصال**: يتصل تطبيق الهاتف بالخادم عبر TCP باستخدام
   [البروتوكول الثنائي المخصص](https://github.com/kitswas/VGP_Data_Exchange)
   (حزم `GamepadReading` بترميز Colfer)، ويفك ترميزها ملف `lib/protocol.dart`.

2. **التنفيذ**: كل هاتف يحصل على جلسة `DeviceSession`
   (`lib/device_server.dart`) بسوكت ومخزن ومُنفِّذ خاص به. تُحوَّل الحزم إلى
   أحداث إدخال على مستوى النظام عبر مُنفِّذين (`lib/executors.dart`):
   - **يد تحكم افتراضية**: جهاز افتراضي لكل هاتف (`Virtual Gamepad PC`،
     `Virtual Gamepad PC 2`، …) بمعرّفات متوافقة مع يد Xbox 360 — للألعاب
     التي تدعم يد التحكم وللعب الجماعي المحلي.
   - **محاكاة لوحة المفاتيح والفأرة**: بالأزرار والاتجاهات حسب التعيين
     الافتراضي (نفس تعيينات التطبيق الأصلي) — للألعاب بدون دعم يد التحكم.
     (محرر التعيينات المخصصة لم يُنقل بعد.)

   الحقن يتم عبر [`uinput`/`libevdev`](https://www.kernel.org/doc/html/v6.0/input/uinput.html)
   باستخدام Dart FFI (`lib/linux_input.dart`). _لا حاجة لأي تعريفات خارجية._

3. **مدير بنافذة واحدة**: التطبيق (`lib/app.dart` و`lib/page_*.dart`) نافذة
   أحادية اللون: حالة الخادم مع زر تشغيل/إيقاف، ولوحة توصيل الهواتف (قائمة
   IP ورمز QR)، وقائمة الأجهزة المتصلة مع إحصاءات لكل جهاز وأزرار القطع —
   **ويمكن إعادة تسمية كل جهاز** (يُحفظ الاسم حسب عنوان IP). الإعدادات
   (طريقة الإدخال، المنفذ، سرعة المؤشر، **اللغة: العربية افتراضيًا وRTL
   مع خيار الإنجليزية**) وحول التطبيق في نفس النافذة، والخادم يستمر
   بالعمل تحتها.

4. **الأمان والخصوصية**: كل الاتصالات محلية (Wi-Fi/LAN). لا إعلانات ولا
   تتبع. الكود مفتوح للمراجعة.

## بنية المصدر

- lib - مصدر Dart (البروتوكول، حقن FFI، الخادم، الإعدادات، الواجهة)
- linux - مشغّل Flutter للينكس
- test - اختبارات وحدة وتكامل (Colfer، خادم loopback، أجهزة uinput حقيقية)
- assets - الشعار
- packaging - ملف `.desktop` للينكس
- VGP_Data_Exchange - تعريف بروتوكول الاتصال (submodule للقراءة فقط)
- third-party-libs - مكتبات خارجية (محفوظة كما هي)

## البناء

انظر [ملف البناء](Build.md). باختصار:

```bash
flutter pub get
flutter analyze && flutter test
flutter run -d linux
```

## الرخصة

GPL-3.0 — انظر [LICENCE.TXT](LICENCE.TXT).

---

**للاستخدام والتنزيلات وحل المشاكل، زر [الموقع الرئيسي](https://kitswas.github.io/VirtualGamePad/).**
