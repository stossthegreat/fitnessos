import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_config.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFBBF24),
          ),
        ),
      );
    }

    final goal = GoalConfig.get(user.goalMode);
    final equipment = EquipmentConfig.get(user.equipmentMode);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 24),
      child: Column(
        children: [
          // OS Mode Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.amberGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber400.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SYSTEM MODE',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.white60,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Pattern Drift',
                                style: AppTextStyles.h2,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.black20,
                              border: Border.all(color: AppColors.white10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.amber300,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Day ${user.dayStreak}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip('Goal: ${goal.short}', goal.color),
                          _buildChip('Equipment: ${equipment.label}', Colors.white),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Behavioral warning active',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white90,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Mission
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR MISSION TODAY',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '18-minute Upper Body Reset',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white5,
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why this matters',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You've missed two sessions. This stops the pattern from deepening. Not perfection. Just presence.",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white90,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('BEGIN SESSION'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Voice
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.slate900, AppColors.slate800],
              ),
              border: Border.all(color: AppColors.slate500.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.track_changes,
                      color: AppColors.slate300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'The Tactical Instructor says',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"Your compliance dropped 15% after late meetings. Morning sessions are tactical."',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white90,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Change voice',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Week Pattern
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK\'S PATTERN',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final values = user.weekPattern;
                      final value = values[index];
                      final day = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                      final color = value >= 80
                          ? AppColors.emerald500
                          : value >= 60
                              ? AppColors.amber400
                              : AppColors.rose500;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: value.toDouble(),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                day,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.white40,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatRow('Compliance', '${user.compliance}%'),
                const SizedBox(height: 8),
                _buildStatRow('Readiness', '${user.readiness}%'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reality Check
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.roseGradient[0].withOpacity(0.5),
                  AppColors.roseGradient[1].withOpacity(0.5),
                ],
              ),
              border: Border.all(color: AppColors.rose500.withOpacity(0.2)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        color: AppColors.rose300,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reality check',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.rose300,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    'Training this week',
                    '${user.trainingHours} hours',
                    color: AppColors.rose300,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'Netflix this week',
                    '${user.netflixHours} hours',
                    color: AppColors.rose300,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.rose400, width: 0.5),
                      ),
                    ),
                    child: Text(
                      'This is your pattern.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.rose300.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.black60,
        border: Border.all(color: AppColors.white10),
      ),
      child: child,
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.black30,
        border: Border.all(color: AppColors.white10),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelTiny.copyWith(
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ?? AppColors.white70,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ?? Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

