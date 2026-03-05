import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:bl_inshort/features/settings/controllers/settings_controller.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final interests = settingsState.interests;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ... (Top Bar and Info Banner remain same)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3300),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6B5E00)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '“Relevancy” has now changed to “Your Preferences”.',
                        style: TextStyle(
                          color: Color(0xFFFFF1A8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your Preferences',
              style: TextStyle(
                color: Color(0xFF4EA3FF),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'You\'ll see more shorts from topics marked as "Interested 👍" '
                'and less from topics marked as "Not Interested 👎".\n\n'
                'Feel free to add or remove topics to personalize your feed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  _FilterChip(title: 'All', selected: true),
                  SizedBox(width: 10),
                  _FilterChip(title: 'Interested'),
                  SizedBox(width: 10),
                  _FilterChip(title: 'Not Interested'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _PreferenceTile(
                    title: 'Automobile',
                    icon: Icons.directions_car,
                    preference:
                        interests['Automobile'] ?? InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Automobile', pref),
                  ),
                  _PreferenceTile(
                    title: 'Business',
                    icon: Icons.work,
                    preference:
                        interests['Business'] ?? InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Business', pref),
                  ),
                  _PreferenceTile(
                    title: 'Education',
                    icon: Icons.school,
                    preference:
                        interests['Education'] ?? InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Education', pref),
                  ),
                  _PreferenceTile(
                    title: 'Entertainment',
                    icon: Icons.music_note,
                    preference:
                        interests['Entertainment'] ??
                        InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Entertainment', pref),
                  ),
                  _PreferenceTile(
                    title: 'Fashion',
                    icon: Icons.checkroom,
                    preference:
                        interests['Fashion'] ?? InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Fashion', pref),
                  ),
                  _PreferenceTile(
                    title: 'Hatke',
                    icon: Icons.blur_on,
                    preference:
                        interests['Hatke'] ?? InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Hatke', pref),
                  ),
                  _PreferenceTile(
                    title: 'Miscellaneous',
                    icon: Icons.category,
                    preference:
                        interests['Miscellaneous'] ??
                        InterestPreference.neutral,
                    onChanged: (pref) => ref
                        .read(settingsControllerProvider.notifier)
                        .setInterest('Miscellaneous', pref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String title;
  final bool selected;

  const _FilterChip({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF102A44) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF4EA3FF) : const Color(0xFF2A2A2A),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF4EA3FF) : Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final InterestPreference preference;
  final Function(InterestPreference) onChanged;

  const _PreferenceTile({
    required this.title,
    required this.icon,
    required this.preference,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1F1F1F),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          _ActionIcon(
            icon: preference == InterestPreference.interested
                ? Icons.thumb_up_alt
                : Icons.thumb_up_alt_outlined,
            active: preference == InterestPreference.interested,
            activeColor: Colors.green,
            onTap: () {
              onChanged(
                preference == InterestPreference.interested
                    ? InterestPreference.neutral
                    : InterestPreference.interested,
              );
            },
          ),
          const SizedBox(width: 10),
          _ActionIcon(
            icon: preference == InterestPreference.notInterested
                ? Icons.thumb_down_alt
                : Icons.thumb_down_alt_outlined,
            active: preference == InterestPreference.notInterested,
            activeColor: Colors.red,
            onTap: () {
              onChanged(
                preference == InterestPreference.notInterested
                    ? InterestPreference.neutral
                    : InterestPreference.notInterested,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    this.active = false,
    this.activeColor = const Color(0xFF4EA3FF),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: active
              ? activeColor.withOpacity(0.1)
              : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(17),
          border: active
              ? Border.all(color: activeColor.withOpacity(0.5))
              : null,
        ),
        child: Icon(
          icon,
          color: active ? activeColor : const Color(0xFF6F6F6F),
          size: 16,
        ),
      ),
    );
  }
}
