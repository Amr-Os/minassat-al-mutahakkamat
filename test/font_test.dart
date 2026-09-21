import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled Naskh font loads', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = FontLoader('NaskhTest');
    loader.addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
    loader.addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'));
    await loader.load();
  });
}
