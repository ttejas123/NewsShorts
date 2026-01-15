import 'package:bl_inshort/app/app.dart';
import 'package:flutter/widgets.dart';

class LanguageLocalization extends StatelessWidget {
  final String languageCode; // en / hi / ar
  final Widget child;

  const LanguageLocalization({
    super.key,
    required this.languageCode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: Locale(languageCode),
      child: child,
    );
  }
}
