import 'package:bl_inshort/core/config/globles.dart';
import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/onboarding/presentation/language_localization.dart';
import 'package:bl_inshort/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../settings/provider.dart';

class Region {
  final String name;
  final String svg;

  Region({required this.name, required this.svg});
}

class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key, required this.language});
  final LanguageEntity language;

  @override
  ConsumerState<RegionSelectionScreen> createState() =>
      _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  final Set<String> _selectedRegions = {};

  static final List<Region> regions = [
    Region(name: 'Europe', svg: 'assets/europe.svg'),
    Region(name: 'Africa', svg: 'assets/africa.svg'),
    Region(name: 'India', svg: 'assets/india.svg'),
    Region(name: 'Pakistan', svg: 'assets/pakistan.svg'),
    Region(name: 'Philippines', svg: 'assets/philippines.svg'),
    Region(name: 'South America', svg: 'assets/southAmerica.svg'),
    Region(name: 'North America', svg: 'assets/northAmerica.svg'),
    Region(name: 'Finland', svg: 'assets/finland.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LanguageLocalization(
          languageCode: widget.language.code,
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  /// Back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: theme.colorScheme.primary,
                      onPressed: () => context.go('/'),
                    ),
                  ),

                  /// Title
                  Text(
                    context.l10n.onboardingRegionTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      context.l10n.onboardingRegionDesc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: regions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (_, index) {
                        final region = regions[index];
                        final selected = _selectedRegions.contains(region.name);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedRegions.remove(region.name);
                              } else {
                                _selectedRegions.add(region.name);
                              }
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  region.svg,
                                  width: 80,
                                  height: 80,
                                  colorFilter: ColorFilter.mode(
                                    theme.colorScheme.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  region.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// Next
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 24),
                    child: SizedBox(
                      width: 220,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedRegions.isEmpty
                            ? null
                            : () async {
                                await controller.selectLanguage(
                                  widget.language,
                                );
                                await controller.setSelectedRegions(
                                  _selectedRegions,
                                );
                              },
                        child: Text(context.l10n.onboardingRegionNext),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
