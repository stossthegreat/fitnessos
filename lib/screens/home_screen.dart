import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';
import 'tabs/home_tab.dart';
import 'tabs/train_tab.dart';
import 'tabs/camera_tab.dart';
import 'tabs/you_tab.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    TrainTab(),
    CameraTab(),
    YouTab(),
  ];

  final List<_TabInfo> _tabInfo = const [
    _TabInfo(icon: Icons.home, label: 'Home'),
    _TabInfo(icon: Icons.fitness_center, label: 'Train'),
    _TabInfo(icon: Icons.apple, label: 'Fuel'),
    _TabInfo(icon: Icons.person, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.blackGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.black90,
            border: const Border(
              top: BorderSide(color: AppColors.white10, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabInfo.length, (index) {
                  final tab = _tabInfo[index];
                  final isActive = _currentIndex == index;

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isActive
                              ? AppColors.amber400
                              : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.icon,
                              color: isActive ? Colors.black : AppColors.white50,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isActive ? Colors.black : AppColors.white50,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;

  const _TabInfo({
    required this.icon,
    required this.label,
  });
}

