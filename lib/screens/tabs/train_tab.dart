import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_template.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../workout/workout_session_screen.dart';

class TrainTab extends ConsumerWidget {
  const TrainTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = WorkoutTemplates.getAll();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Train', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Select your workout for today',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white60,
            ),
          ),
          const SizedBox(height: 32),
          
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.slate950, AppColors.slate900],
              ),
              border: Border.all(color: AppColors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('🔥', 'Streak', '12 days'),
                _buildQuickStat('💪', 'This Week', '4 sessions'),
                _buildQuickStat('📈', 'Volume', '+8%'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'WORKOUT TEMPLATES',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white60,
            ),
          ),
          const SizedBox(height: 16),
          
          // Workout Templates
          ...templates.map((template) => _buildWorkoutCard(
            context,
            template,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutSessionScreen(template: template),
                ),
              );
            },
          )),
          
          const SizedBox(height: 16),
          
          // Custom Workout
          _buildCustomWorkoutCard(context),
        ],
      ),
    );
  }
  
  Widget _buildQuickStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.white50,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWorkoutCard(
    BuildContext context,
    WorkoutTemplate template,
    {required VoidCallback onTap}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.amber400.withOpacity(0.1),
                  AppColors.amber400.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.amber400.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  template.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${template.exercises.length} exercises',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.amber300,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.amber400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomWorkoutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white20,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: AppColors.white50, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Workout',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Build your own session',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
