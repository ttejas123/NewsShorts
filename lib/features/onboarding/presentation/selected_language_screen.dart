import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/onboarding/presentation/language_localization.dart';
import 'package:bl_inshort/features/onboarding/presentation/region_selection_screen.dart';
import 'package:bl_inshort/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:bl_inshort/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedLanguageScreen extends ConsumerWidget {
  final String language;

  const SelectedLanguageScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = language == 'en' ? 'English' : 'العربية';
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LanguageLocalization(
          languageCode: language,
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  /// ───── Back ─────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: theme.colorScheme.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Spacer(),

                  /// ───── Card ─────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 140,
                        height: 160,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.article,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(label, style: textTheme.labelLarge),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ───── Text ─────
                  Text(
                    context.l10n.selectedLanguageTitle,
                    style: textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      context.l10n.selectedLanguageDesc,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// ───── Button ─────
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        _goNext(
                          context,
                          LanguageEntity(
                            id: language == 'en' ? 1 : 2,
                            name: label,
                            code: language,
                          ),
                        );
                      },
                      child: Text(context.l10n.selectedLanguageNext),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _goNext(BuildContext context, LanguageEntity language) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegionSelectionScreen(language: language),
      ),
    );
  }
}
