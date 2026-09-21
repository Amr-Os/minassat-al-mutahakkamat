// About page. Original project by kitswas — credited here and in README.

import 'package:flutter/material.dart';

import 'l10n.dart';
import 'theme.dart';
import 'widgets.dart';

const String appVersion = '0.6.1';

class AboutPage extends StatelessWidget {
  final AppLanguage language;
  const AboutPage({super.key, this.language = AppLanguage.arabic});

  @override
  Widget build(BuildContext context) {
    final s = stringsFor(language);
    return SingleChildScrollView(
      child: MonoCard(
        title: s.aboutHeading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', width: 64, height: 64),
                const SizedBox(width: 12),
                Text(s.versionLabel(appVersion),
                    style: const TextStyle(color: Mono.text)),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              s.aboutBody,
              style: const TextStyle(color: Mono.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
