import 'package:bl_inshort/core/logging/Console.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SpriteIcon extends StatelessWidget {
  final int index;
  final double size;
  final double clipScale;
  final double contentScale;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const SpriteIcon({
    super.key,
    required this.index,
    this.size = 100,
    this.clipScale = 1.4,
    this.contentScale = 1.3,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.borderColor = Colors.black12,
    this.borderWidth = 1.5,
    this.borderRadius = 12,
  });

  static const int columns = 3;
  static const int rows = 4;

  static const double spriteWidth = 2048;
  static const double spriteHeight = 2048;

  static const double cellWidth = spriteWidth / columns;
  static const double cellHeight = spriteHeight / rows;

  @override
  Widget build(BuildContext context) {
    final row = index ~/ columns;
    final col = index % columns;

    final baseScale = size / cellHeight;
    final iconScale = baseScale * contentScale;
    final clipSize = size * clipScale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Container(
          width: clipSize,
          height: clipSize,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius - 4),
          ),
          child: ClipRRect(
            // 👈 better than ClipRect for rounded border
            borderRadius: BorderRadius.circular(borderRadius - 4),
            child: Transform.scale(
              scale: iconScale,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(-col * cellWidth, -row * cellHeight),
                child: SizedBox(
                  width: spriteWidth,
                  height: spriteHeight,
                  child: Image.asset(
                    'assets/images/category_sprite.png',
                    fit: BoxFit.none,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  const CategoryIcon({
    super.key,
    required this.asset,
    this.size = 100,
    this.backgroundColor = Colors.white60,
    this.iconColor = Colors.black,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: size * 0.8,
          height: size * 0.8,
          color: iconColor,
        ),
      ),
    );
  }
}

class SplashIntroScreen extends ConsumerStatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  ConsumerState<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends ConsumerState<SplashIntroScreen> {
  int index = 0;

  final items = [
    {'icon': 'assets/icons/science.svg', 'text': 'Science'},
    {'icon': 'assets/icons/travel.svg', 'text': 'Travel'},
    {'icon': 'assets/icons/fashion.svg', 'text': 'Fashion'},
    {'icon': 'assets/icons/technology.svg', 'text': 'Technology'},
    {'icon': 'assets/icons/music.svg', 'text': 'Music'},
    {'icon': 'assets/icons/business.svg', 'text': 'Business'},
    {'icon': 'assets/icons/edu.svg', 'text': 'Education'},
    {'icon': 'assets/icons/cricket.svg', 'text': 'Cricket'},
    {'icon': 'assets/icons/sports.svg', 'text': 'Sports'},
    {'icon': 'assets/icons/word.svg', 'text': 'World'},
    {'icon': 'assets/icons/politics.svg', 'text': 'Politics'},
    {'icon': 'assets/icons/property.svg', 'text': 'Property'},
  ];

  @override
  void initState() {
    super.initState();

    _animate();
  }

  Future<void> _animate() async {
    final controller = ref.read(settingsControllerProvider.notifier);
    for (int i = 0; i < items.length; i++) {
      if (!mounted) return;

      setState(() => index = i);

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (mounted) {
      controller.setOnboardingIntroCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCD0100),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Column(
            key: ValueKey(index),
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryIcon(asset: items[index]['icon']!),

              const SizedBox(height: 16),
              Text(
                items[index]['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
