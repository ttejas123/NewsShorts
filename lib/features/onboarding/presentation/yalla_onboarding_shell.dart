import 'package:flutter/material.dart';

class YallaOnboardingShell extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  final bool showBack;
  final VoidCallback? onBack;

  const YallaOnboardingShell({
    super.key,
    required this.child,
    this.bottom,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD50000),
              Color(0xFFB71C1C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [

            /// 🏙 Skyline Background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/skyline.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),

            /// 🔴 Content Layer
            SafeArea(
              child: Column(
                children: [

                  /// Optional Back
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: onBack,
                      ),
                    ),

                  const SizedBox(height: 8),

                  /// Title
                  const Text(
                    "Yalla News",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "news on the go",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Middle Content
                  Expanded(
                    child: child,
                  ),

                  /// Optional Bottom
                  if (bottom != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                        top: 16,
                      ),
                      child: bottom!,
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
