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
            colors: [Color(0xFFD50000), Color(0xFFB71C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
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

            /// 🔴 Content Layer
            SafeArea(
              child: Column(
                children: [
                  /// Optional Back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Visibility(
                      visible: showBack,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: onBack,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Title
                  const Text(
                    "Yalla News",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.white30,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 0),

                  const Text(
                    "news on the go",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Middle Content
                  Expanded(child: child),

                  /// Optional Bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80, top: 16),
                    child: Visibility(
                      visible: bottom != null,
                      child: bottom ?? const SizedBox(height: 50),
                    ),
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
