import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_config.dart';
import '../../models/exercise_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/workout_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

class TrainTab extends ConsumerWidget {
  const TrainTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final exercises = ref.watch(todayExercisesProvider);
    final weekSchedule = ref.watch(weekScheduleProvider);
    final recentSessions = ref.watch(recentSessionsProvider);

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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Train', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            'Today is built for your goal and equipment.',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.white60),
          ),
          const SizedBox(height: 24),

          // Goal Selector
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOAL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: GoalMode.values.map((mode) {
                      final config = GoalConfig.get(mode);
                      final isActive = user.goalMode == mode;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(userProvider.notifier).updateGoal(mode);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isActive
                                  ? AppColors.amber400
                                  : AppColors.black40,
                              border: Border.all(
                                color: isActive
                                    ? AppColors.amber300
                                    : AppColors.white15,
                              ),
                            ),
                            child: Text(
                              config.short,
                              style: AppTextStyles.labelTiny.copyWith(
                                color: isActive ? Colors.black : AppColors.white70,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.white60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Equipment Selector
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EQUIPMENT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: EquipmentMode.values.map((mode) {
                    final config = EquipmentConfig.get(mode);
                    final isActive = user.equipmentMode == mode;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(userProvider.notifier).updateEquipment(mode);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isActive
                                  ? AppColors.emerald400.withOpacity(0.9)
                                  : AppColors.black40,
                              border: Border.all(
                                color: isActive
                                    ? AppColors.emerald300
                                    : AppColors.white15,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  config.label,
                                  style: AppTextStyles.labelTiny.copyWith(
                                    color: isActive ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.description,
                                  style: AppTextStyles.labelTiny.copyWith(
                                    color: isActive
                                        ? AppColors.black60
                                        : AppColors.white60,
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Session
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.slate950, Colors.black],
              ),
              border: Border.all(color: AppColors.amber400.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber400.withOpacity(0.1),
                  blurRadius: 30,
                ),
              ],
            ),
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
                          'TODAY\'S SESSION',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.amber400.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '18-minute Upper Body Reset',
                          style: AppTextStyles.h2,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.analytics, color: AppColors.white60, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      '${user.readiness}% readiness',
                      style: AppTextStyles.labelTiny.copyWith(
                        color: AppColors.white60,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.bolt, color: AppColors.amber300, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Auto-scaled for ${goal.short}',
                      style: AppTextStyles.labelTiny.copyWith(
                        color: AppColors.white60,
                      ),
                    ),
                  ],
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
                        'Session intent',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white60,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Short, high-return work matched to your goal and what you actually have access to. Volume is capped to avoid burnout but enough to keep momentum and signal your body to adapt.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white80,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Exercise List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.black60,
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EXERCISES IN THIS BLOCK',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.white60,
                            ),
                          ),
                          Text(
                            'Auto-loaded by OS',
                            style: AppTextStyles.labelTiny.copyWith(
                              color: AppColors.white40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...exercises.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ex = entry.value;
                        return _buildExerciseCard(ex, index + 1);
                      }),
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

          // This Week
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 16),
                ...weekSchedule.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                item['day'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white70,
                                ),
                              ),
                            ),
                            Text(
                              item['workout'],
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (item['status'] == 'complete')
                          const Text(
                            '✓',
                            style: TextStyle(color: AppColors.emerald400),
                          ),
                        if (item['status'] == 'today')
                          Text(
                            '← Today',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.amber400,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Sessions
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECENT SESSIONS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 16),
                ...recentSessions.map((session) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.white5,
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                session.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: session.status.name == 'complete'
                                    ? AppColors.emerald500.withOpacity(0.2)
                                    : AppColors.rose500.withOpacity(0.2),
                              ),
                              child: Text(
                                session.statusLabel,
                                style: AppTextStyles.labelTiny.copyWith(
                                  color: session.status.name == 'complete'
                                      ? AppColors.emerald300
                                      : AppColors.rose300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${session.dateRelative}${session.durationMinutes != null ? " • ${session.durationMinutes} minutes" : ""}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white50,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.black60,
        border: Border.all(color: AppColors.white10),
      ),
      child: child,
    );
  }

  Widget _buildExerciseCard(Exercise ex, int index) {
    Color difficultyColor;
    Color difficultyBorderColor;
    
    switch (ex.difficulty) {
      case ExerciseDifficulty.easy:
        difficultyColor = AppColors.emerald300;
        difficultyBorderColor = AppColors.emerald400.withOpacity(0.5);
        break;
      case ExerciseDifficulty.medium:
        difficultyColor = AppColors.amber300;
        difficultyBorderColor = AppColors.amber400.withOpacity(0.6);
        break;
      case ExerciseDifficulty.hard:
        difficultyColor = AppColors.rose300;
        difficultyBorderColor = AppColors.rose400.withOpacity(0.6);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white5,
        border: Border.all(color: AppColors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$index',
                      style: AppTextStyles.labelTiny.copyWith(
                        color: AppColors.white40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ex.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ex.muscles,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.black40,
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: Text(
                        '${ex.sets} sets × ${ex.reps}',
                        style: AppTextStyles.labelTiny.copyWith(
                          color: AppColors.white50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: difficultyBorderColor),
                      ),
                      child: Text(
                        ex.difficultyLabel,
                        style: AppTextStyles.labelTiny.copyWith(
                          color: difficultyColor,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [AppColors.slate700, AppColors.slate900],
              ),
              border: Border.all(color: AppColors.white10),
            ),
            child: Center(
              child: Text(
                'FORM\nCLIP',
                style: AppTextStyles.labelTiny.copyWith(
                  color: AppColors.white60,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

