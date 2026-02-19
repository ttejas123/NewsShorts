import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/onboarding/presentation/region_selection_screen.dart';
import 'package:bl_inshort/features/onboarding/presentation/yalla_onboarding_shell.dart';
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
    return YallaOnboardingShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Language Dropdown
          Container(
            child: Column(
              children: [
                
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
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegionSelectionScreen(
          language: LanguageEntity(
            id: selected == 'en' ? 1 : 2,
            name: selected == 'en' ? 'English' : 'العربية',
            code: selected,
          ),
        ),
      ),
    );
  }
}
