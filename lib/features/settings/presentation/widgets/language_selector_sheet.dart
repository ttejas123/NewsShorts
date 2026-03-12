import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});
  static final _languages = [
    LanguageEntity(id: 1, code: 'en', name: 'English'),
    LanguageEntity(id: 1, code: 'ar', name: 'العربية'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsControllerProvider).selectedLanguage;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose your language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                ..._languages.map((lang) {
                  final isSelected = selected?.code == lang.code;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .selectLanguage(lang);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: SizedBox(
                          height: 44,
                          child: Center(
                            child: Text(
                              lang.name,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
