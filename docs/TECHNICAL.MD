# التفاصيل التقنية — منصة المتحكمات

هذا الملف للمطورين. دليل الاستخدام في [README.MD](../README.MD).

## البنية

```text
تطبيق الهاتف (TCP) -> DeviceServer (dart:io) -> فك ترميز Colfer
  -> المُنفِّذ (يد uinput | لوحة/فأرة) -> نواة لينكس
```

| الملف | الدور |
|---|---|
| `lib/protocol.dart` | فك/ترميز `GamepadReading` (نقل حرفي لسلوك `VGP_Data_Exchange/C/Colfer.c` — اقرأه قبل لمس الفك) |
| `lib/buttons.dart` | أعلام الأزرار (مطابقة لواجهة Windows API كما في الأصل) |
| `lib/keycodes.dart` | رموز أحداث لينكس (مطابقة لـ `input-event-codes.h`) |
| `lib/linux_input.dart` | ربط FFI مع `libevdev.so.2` وlibc + جهاز uinput مُدار |
| `lib/executors.dart` | `GamepadExecutor` و`KeyboardMouseExecutor` (التعيين الافتراضي) و`NullExecutor` للاختبارات |
| `lib/device_server.dart` | خادم TCP + `DeviceSession` (تخزين مؤقت، إحصاءات، أسماء مخصصة حسب IP) |
| `lib/settings.dart` | إعدادات JSON |
| `lib/l10n.dart` | كل النصوص بالعربية والإنجليزية — أي نص جديد يجب أن يوجد في اللغتين |
| `lib/app.dart` و`lib/page_*.dart` | الواجهة (نافذة واحدة) |

## البروتوكول (Colfer)

حزمة `GamepadReading` = تتابع أزواج (رقم الحقل، القيمة) بترتيب تصاعدي،
يليه بايت الإنهاء `127`:

- الحقلان 0 و1 (`uint32`: الأزرار المرفوعة/المضغوطة): الرأس `i` يليه
  varint، أو الرأس `i|128` يليه 4 بايت big-endian.
- الحقول 2–7 (`float32`: الزنادان والمحورين): الرأس `i` يليه 4 بايت
  big-endian بصيغة IEEE-754.
- الحقول الصفرية يحذفها المرمّز.

الدلالات مطابقة للمولّد C: المدخلات المبتورة = غير مكتملة، تجاوز 16MB =
كبيرة جدًا، أي شيء آخر = عدم تطابق. **لا تكسر صيغة السلك أبدًا** — تطبيقات
الهاتف تعتمد عليها.

## الحقن في لينكس

- **اليد**: جهاز `Minassat Gamepad` (و`Minassat Gamepad 2`، …) بمعرّفات
  Xbox 360 (`045e:028e`) للتوافق. الأزرار ← `BTN_*`، العصي ←
  `ABS_X/Y/RX/RY` بمقياس ±32767، القبعات ← `ABS_HAT0X/Y`، الزنادان ←
  `ABS_Z/RZ` بمقياس 0–255، ثم `SYN_REPORT`. قطبية المحاور مطابقة للتطبيق
  الأصلي.
- **لوحة/فأرة**: جهازا `Minassat Keyboard` و`Minassat Mouse` بالتعيين
  الافتراضي المنقول من الأصل (Enter وEsc وShift وCtrl والأسهم وWASD
  والنقر)، والعصي للفأرة أو الاتجاهات بعتبة 0.5.
- إنشاء الأجهزة يتطلب الوصول إلى `/dev/uinput` (انظر Build.md). عند الفشل
  تبقى الجلسة حية بحالة "محدود" مع السبب بدل قطع الاتصال.

## الجلسات والإعدادات

- لكل هاتف جلسة بسوكت ومخزن وإحصاءات (عدد الطلبات ومتوسط الفاصل).
- الأسماء المخصصة تُحفظ حسب IP في الإعدادات وتُطبق عند الاتصال.
- الإعدادات JSON في `~/.config/minassat-al-mutahakkamat/settings.json`:
  `port` (0 = تلقائي) و`executor` (`gamepad`|`keyboardMouse`)
  و`mouseSensitivity` و`language` (`ar`|`en`) و`deviceNames`.

## الاختبارات

```bash
flutter analyze
flutter test   # يشمل اختبارات uinput حقيقية عند توفر /dev/uinput
```

تغطي الاختبارات: ذهاب وعودة Colfer (بما فيه الصيغة الثابتة والتقطيع
والحزم المتعددة)، خادم loopback (اتصالان، إعادة تشغيل، تعارض المنفذ،
إعادة التسمية)، إنشاء أجهزة uinput حقيقية، وبث 60Hz مع 181 حقنة FFI.

## الشكر والرخصة

المشروع مشتق من [VirtualGamePad-PC](https://github.com/kitswas/VirtualGamePad-PC)
للمطور kitswas (GPL-3.0) — البروتوكول والفكرة والتعيينات الافتراضية من
عمله. هذه النسخة إعادة كتابة بلغة Flutter/Dart وتبقى تحت
[GPL-3.0](../LICENCE.TXT). `VGP_Data_Exchange` submodule للقراءة فقط.
