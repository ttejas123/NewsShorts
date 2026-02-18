import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/onboarding/presentation/region_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:bl_inshort/theme/app_colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selected = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD50000), Color(0xFFB71C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              /// 🔴 Main Content
              Column(
                children: [
                  const SizedBox(height: 120),

                  /// Title
                  const Text(
                    "Yalla News",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 0),

                  /// Subtitle
                  const Text(
                    "news on the go",
                    style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold, color: Colors.white70),
                  ),

                  const SizedBox(height: 80),

                  /// Language Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selected,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selected = value!;
                            });
                            _goNext();
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Select your language",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const Spacer(),
                ],
              ),

              /// 🏙️ Bottom Skyline Image
              Positioned(
                bottom: -20, // 👈 pull image down
                left: 0,
                right: 0,
                child: Transform.scale(
                  scale: 1.25, // 👈 increases skyline size
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/images/skyline.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            
            ],
          ),
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
        builder: (_) => RegionSelectionScreen(language: LanguageEntity(
                            id: selected == 'en' ? 1 : 2,
                            name: selected== 'en' ? 'English' : 'العربية',
                            code: selected,
                          )),
      ),
    );
  }
}