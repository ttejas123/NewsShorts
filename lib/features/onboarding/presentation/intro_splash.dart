import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashIntroScreen extends StatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen> {
  int index = 0;

  final items = [
    {'icon': Icons.public, 'text': 'Global News'},
    {'icon': Icons.trending_up, 'text': 'Trending Stories'},
    {'icon': Icons.category, 'text': 'All Categories'},
    {'icon': Icons.favorite, 'text': 'Personalised For You'},
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (index < items.length - 1) {
        setState(() => index++);
      } else {
        if (mounted) {
          context.go('/');
        }
      }
    });
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
