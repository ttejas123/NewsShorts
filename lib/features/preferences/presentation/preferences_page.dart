import 'package:bl_inshort/features/settings/controllers/settings_controller.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PreferenceTopic {
  final String title;
  final IconData icon;

  const PreferenceTopic({required this.title, required this.icon});
}

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final languageCode = settingsState.selectedLanguage?.code ?? 'en';

    final tags = _getTagsForLanguage(languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Bar
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

            const SizedBox(height: 8),

            // 🔹 Title + Description
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

            // 🔹 Filter Tabs
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

            // 🔹 List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final topic = tags[index];
                  final currentPref = controller.getTopicPreference(topic.title);

                  return _PreferenceTile(
                    title: topic.title,
                    icon: topic.icon,
                    preference: currentPref,
                    onInterested: () => controller.setInterest(
                      topic.title,
                      currentPref == InterestPreference.interested
                          ? InterestPreference.neutral
                          : InterestPreference.interested,
                    ),
                    onNotInterested: () => controller.setInterest(
                      topic.title,
                      currentPref == InterestPreference.notInterested
                          ? InterestPreference.neutral
                          : InterestPreference.notInterested,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PreferenceTopic> _getTagsForLanguage(String lang) {
    if (lang == 'ar') {
      return const [
        PreferenceTopic(title: 'محليات', icon: Icons.location_city),
        PreferenceTopic(title: 'اقتصاد', icon: Icons.show_chart),
        PreferenceTopic(title: 'حياتنا', icon: Icons.favorite),
        PreferenceTopic(title: 'رياضة', icon: Icons.sports_soccer),
        PreferenceTopic(title: 'العالم', icon: Icons.public),
        PreferenceTopic(title: 'صحة', icon: Icons.health_and_safety),
        PreferenceTopic(title: 'تعليم', icon: Icons.school),
        PreferenceTopic(title: 'أخبار', icon: Icons.newspaper),
      ];
    } else {
      return const [
        PreferenceTopic(title: 'World', icon: Icons.public),
        PreferenceTopic(title: 'Economy', icon: Icons.show_chart),
        PreferenceTopic(title: 'Life', icon: Icons.eco),
        PreferenceTopic(title: 'Sports', icon: Icons.sports_basketball),
        PreferenceTopic(title: 'Health', icon: Icons.health_and_safety),
        PreferenceTopic(title: 'Politics', icon: Icons.gavel),
        PreferenceTopic(title: 'Technology', icon: Icons.memory),
        PreferenceTopic(title: 'Security', icon: Icons.security),
        PreferenceTopic(title: 'Business', icon: Icons.business),
        PreferenceTopic(title: 'Science', icon: Icons.science),
      ];
    }
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
  final VoidCallback onInterested;
  final VoidCallback onNotInterested;

  const _PreferenceTile({
    required this.title,
    required this.icon,
    required this.preference,
    required this.onInterested,
    required this.onNotInterested,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          _ActionIcon(
            icon: Icons.thumb_up_alt_outlined,
            activeIcon: Icons.thumb_up_alt,
            selected: preference == InterestPreference.interested,
            onTap: onInterested,
            activeColor: const Color(0xFF4EA3FF),
          ),
          const SizedBox(width: 10),
          _ActionIcon(
            icon: Icons.thumb_down_alt_outlined,
            activeIcon: Icons.thumb_down_alt,
            selected: preference == InterestPreference.notInterested,
            onTap: onNotInterested,
            activeColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _ActionIcon({
    required this.icon,
    required this.activeIcon,
    this.selected = false,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.15) : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(17),
          border: selected ? Border.all(color: activeColor.withOpacity(0.5)) : null,
        ),
        child: Icon(
          selected ? activeIcon : icon,
          color: selected ? activeColor : const Color(0xFF6F6F6F),
          size: 16,
        ),
      ),
    );
  }
}
