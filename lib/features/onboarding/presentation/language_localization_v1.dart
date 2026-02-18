import 'package:flutter/material.dart';
import 'package:bl_inshort/theme/app_colors.dart';
import 'selected_language_screen.dart';

class LanguageSelectionScreenV1 extends StatefulWidget {
  const LanguageSelectionScreenV1({super.key});

  @override
  State<LanguageSelectionScreenV1> createState() =>
      _LanguageSelectionScreenV1State();
}

class _LanguageSelectionScreenV1State extends State<LanguageSelectionScreenV1> {
  String selected = 'en';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            /// ───── Title ─────
            Text(
              'Yalla News',
              style: textTheme.headlineMedium?.copyWith(color: colors.primary),
            ),

            const SizedBox(height: 50),

            /// ───── Language Cards ─────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _languageCard(
                  context,
                  label: 'English',
                  iconText: 'NEWS',
                  isSelected: selected == 'en',
                  onTap: () {
                    setState(() => selected = 'en');
                    _goNext();
                  },
                ),
                const SizedBox(width: 20),
                _languageCard(
                  context,
                  label: 'العربية',
                  iconText: 'أخبار',
                  isSelected: selected == 'ar',
                  onTap: () {
                    setState(() => selected = 'ar');
                    _goNext();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ───── Check Icons ─────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _checkIcon(selected == 'en'),
                const SizedBox(width: 140),
                _checkIcon(selected == 'ar'),
              ],
            ),

            const Spacer(),

            /// ───── Bottom Text ─────
            Text(
              'Choose Language',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر اللغة',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _languageCard(
    BuildContext context, {
    required String label,
    required String iconText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    iconText,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  Icon(Icons.article, color: colors.primary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: textTheme.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _checkIcon(bool active) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active ? AppColors.success : AppColors.lightDivider,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white.withOpacity(active ? 1 : 0.4),
      ),
    );
  }

  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectedLanguageScreen(language: selected),
      ),
    );
  }
}
