import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';
import 'onboarding/onboarding_main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final unitsMetric = ref.watch(unitsMetricProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

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
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              Text(
                'ACCOUNT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    if (user != null) ...[
                      _buildSettingItem(
                        icon: Icons.person,
                        title: 'Name',
                        subtitle: user.name,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: 'Not set',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.photo_camera,
                        title: 'Profile Picture',
                        subtitle: 'Add photo',
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Preferences Section
              Text(
                'PREFERENCES',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildSettingToggle(
                      icon: Icons.straighten,
                      title: 'Metric Units',
                      subtitle: 'Use kg instead of lbs',
                      value: unitsMetric,
                      onChanged: (value) {
                        ref.read(unitsMetricProvider.notifier).toggle();
                      },
                    ),
                    _buildDivider(),
                    _buildSettingToggle(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Daily reminders and insights',
                      value: notificationsEnabled,
                      onChanged: (value) {
                        ref.read(notificationsEnabledProvider.notifier).toggle();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Appearance Section
              Text(
                'APPEARANCE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: 'Dark (default)',
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 32),

              // About Section
              Text(
                'ABOUT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.info,
                      title: 'App Version',
                      subtitle: '1.0.0',
                      onTap: null,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.code,
                      title: 'Developer',
                      subtitle: 'FitnessOS Team',
                      onTap: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Legal Section
              Text(
                'LEGAL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.description,
                      title: 'Terms of Service',
                      onTap: () => _launchURL('https://example.com/terms'),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () => _launchURL('https://example.com/privacy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Actions
              _buildCard(
                child: _buildSettingItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: AppColors.rose400,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.black60,
        border: Border.all(color: AppColors.white10),
      ),
      child: child,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? AppColors.white60,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white50,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.white40,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.white60,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white50,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.amber400,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.white10,
      indent: 56,
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate900,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout? You will need to complete onboarding again.',
          style: TextStyle(color: AppColors.white80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(userProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingMain()),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.rose400),
            ),
          ),
        ],
      ),
    );
  }
}

