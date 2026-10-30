import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../ui/image_placeholder.dart';

class _Page {
  const _Page(this.number, this.title, this.body, this.dark, this.colors);
  final String number;
  final String title;
  final String body;
  final bool dark;
  final List<Color> colors;
}

const _pages = [
  _Page(
      '01',
      'Discover\nWhat Moves\nYou',
      'Explore clubs, workshops\nand events that match\nyour passion.',
      false,
      [Color(0xFFF2F5FA), Color(0xFFB9CBE3), Color(0xFF6E8B66)]),
  _Page(
      '02',
      'Meet\nLike-Minded\nPeople',
      'Find your community\nand build lifelong\nconnections.',
      true,
      [Color(0xFF0B1326), Color(0xFF1C2A44), Color(0xFF3A4660)]),
  _Page(
      '03',
      'Create\nReal Impact',
      'Volunteer, organize\nand contribute to a\nstronger campus.',
      false,
      [Color(0xFFF2F5FA), Color(0xFFCBD6E6), Color(0xFF7C9A6E)]),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      Navigator.of(context).pushReplacementNamed(Routes.signIn);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = _pages[_index].dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _OnboardingPage(page: _pages[i]),
          ),
          Positioned(
            left: 28,
            bottom: 36,
            child: Row(
              children: [
                for (var i = 0; i < _pages.length; i++)
                  Container(
                    width: i == _index ? 10 : 7,
                    height: i == _index ? 10 : 7,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? (dark ? Colors.white : AppColors.ink)
                          : Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 28,
            bottom: 28,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _next,
                child: const SizedBox(
                  width: 68,
                  height: 68,
                  child:
                      Icon(Icons.arrow_forward, color: AppColors.ink, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    final fg = page.dark ? Colors.white : AppColors.ink;
    final bg = page.dark ? AppColors.navy : const Color(0xFFF7F8FB);
    final height = MediaQuery.of(context).size.height;
    return Container(
      color: bg,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.46,
            child: ImagePlaceholder(
              colors: page.colors,
              radius: 0,
              icon: Icons.photo_outlined,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 90, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.number,
                    style: TextStyle(color: fg.withAlpha(150), fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    page.title,
                    style: TextStyle(
                      color: fg,
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    page.body,
                    style: TextStyle(
                      color: fg.withAlpha(170),
                      fontSize: 18,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
