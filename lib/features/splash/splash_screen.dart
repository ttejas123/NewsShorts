import 'package:bl_inshort/core/logging/Console.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashIntroScreen extends ConsumerStatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  ConsumerState<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends ConsumerState<SplashIntroScreen> {
  int index = 0;

  final items = [
    {'icon': Icons.public, 'text': 'World News'},
    {'icon': Icons.movie, 'text': 'Cinema'},
    {'icon': Icons.account_balance, 'text': 'Finance'},
    {'icon': Icons.currency_bitcoin, 'text': 'Crypto'},
    {'icon': Icons.home_work, 'text': 'Property'},
    {'icon': Icons.sports_soccer, 'text': 'Sports'},
    {'icon': Icons.location_city, 'text': 'Local News'},
    {'icon': Icons.language, 'text': 'World News'},
    {'icon': Icons.flag, 'text': 'Europe'},
    {'icon': Icons.public, 'text': 'America'},
    {'icon': Icons.public, 'text': 'Asia'},
    {'icon': Icons.public, 'text': 'Middle East'},
    {'icon': Icons.public, 'text': 'Russia'},
    {'icon': Icons.science, 'text': 'Science'},
    {'icon': Icons.flight, 'text': 'Travel'},
    {'icon': Icons.checkroom, 'text': 'Fashion'},
    {'icon': Icons.directions_car, 'text': 'Automobile'},
    {'icon': Icons.devices, 'text': 'Technology'},
    {'icon': Icons.tv, 'text': 'Entertainment'},
    {'icon': Icons.sports_cricket, 'text': 'Cricket'},
    {'icon': Icons.business, 'text': 'Business'},
    {'icon': Icons.school, 'text': 'Education'},
    {'icon': Icons.account_balance, 'text': 'Politics'},
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
              Icon(
                items[index]['icon'] as IconData,
                color: Colors.white,
                size: 80,
              ),
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
