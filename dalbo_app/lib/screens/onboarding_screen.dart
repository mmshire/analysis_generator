import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../core/theme.dart';

class _Page {
  final String emoji, title, body;
  const _Page(this.emoji, this.title, this.body);
}

const _pages = [
  _Page('🍽️', 'Order from the best', 'Browse top restaurants in Hargeisa and order in seconds.'),
  _Page('🛵', 'Fast delivery', 'Riders bring your food hot and fresh right to your door.'),
  _Page('💰', 'Pay your way', 'Cash on delivery — Zaad & eDahab coming soon.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current    = 0;

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.phoneLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.phoneLogin),
                child: const Text('Skip', style: TextStyle(color: AppColors.textMid)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 100)),
                        const SizedBox(height: 32),
                        Text(p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        Text(p.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: AppColors.textMid, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _current == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _current == i ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            const SizedBox(height: 32),

            // Next / Get started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_current == _pages.length - 1 ? 'Get Started' : 'Next'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
