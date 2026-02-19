import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/onboarding/presentation/yalla_onboarding_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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

    return YallaOnboardingShell(
      showBack: true,
      onBack: () => Navigator.pop(context),


      /// 👇 BOTTOM BUTTON
      bottom: SizedBox(
        width: 280,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _selectedRegions.isEmpty
              ? null
              : () async {
                  await controller.selectLanguage(widget.language);
                  await controller.setSelectedRegions(_selectedRegions);
                },
          child: const Text(
            "Next",
            style: TextStyle(
              color: Color(0xFFD50000),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    
            /// 👇 CENTER CONTENT
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          itemCount: regions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (_, index) {
            final region = regions[index];
            final selected = _selectedRegions.contains(region.name);

            return _buildRegionCard(region, selected);
          },
        ),
      ),

    );
  }


  Widget _buildRegionCard(Region region, bool selected) {
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
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          /// 🔴 Red Icon Box
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFD50000),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SvgPicture.asset(
              region.svg,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// 🌍 Region Name
          Expanded(
            child: Text(
              region.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// ✅ Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFD50000)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check,
              size: 18,
              color: selected
                  ? Colors.white
                  : Colors.white70,
            ),
          ),
        ],
      ),
    ),
  );
}

}
