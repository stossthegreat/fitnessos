import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_config.dart';
import '../../providers/user_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

class FuelTab extends ConsumerWidget {
  const FuelTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final nutrition = ref.watch(nutritionDayProvider);
    final analysis = ref.watch(fuelAnalysisProvider);

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
          const Text('Fuel', style: AppTextStyles.h1),
          const SizedBox(height: 24),

          // AI Fuel Snapshot
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.slate950, AppColors.slate900, Colors.black],
              ),
              border: Border.all(color: AppColors.white15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.emerald400,
                        AppColors.amber300,
                        AppColors.rose400,
                      ],
                    ),
                    border: Border.all(color: AppColors.white20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber400.withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.white20),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.black30,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const Icon(
                              Icons.apple,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI FUEL SNAPSHOT — ${goal.short}',
                        style: AppTextStyles.labelTiny.copyWith(
                          color: AppColors.white50,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['label']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['mood']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        analysis['risk']!,
                        style: AppTextStyles.labelTiny.copyWith(
                          color: AppColors.amber300.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Nutrition
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.slate950, Colors.black],
              ),
              border: Border.all(color: AppColors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${nutrition.todayCalories}',
                      style: AppTextStyles.display2.copyWith(fontSize: 40),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'of ${nutrition.targetCalories} calories',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.white10,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (nutrition.calorieRatio).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [AppColors.amber400, AppColors.orange500],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard(
                        'Protein',
                        '${nutrition.protein}g',
                        'of ${nutrition.targetProtein}g',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard('Carbs', '${nutrition.carbs}g', ''),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard('Fats', '${nutrition.fats}g', ''),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Add meal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: const Text('Photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.white10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.white10,
                        ),
                        child: const Text('Scan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Meals
          _buildGlassCard(
            child: Column(
              children: [
                ...nutrition.meals.map((meal) {
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${meal.name} • ${meal.time}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meal.items,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.white50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${meal.calories} cal',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${meal.protein}g protein',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.white50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.white20,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '+ Add dinner',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white50,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pattern Insight
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.purpleGradient[0].withOpacity(0.5),
                  AppColors.purpleGradient[1].withOpacity(0.5),
                ],
              ),
              border: Border.all(color: AppColors.indigo300.withOpacity(0.2)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pattern insight',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.indigo300,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need ${(nutrition.targetProtein - nutrition.protein).clamp(0, double.infinity).round()}g more protein today for your current goal.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.indigo300.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Weekend binge cycle starts Thursday evening.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.indigo300.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Consider logging Friday dinner now.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.indigo300.withOpacity(0.7),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.black60,
        border: Border.all(color: AppColors.white10),
      ),
      child: child,
    );
  }

  Widget _buildMacroCard(String label, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white5,
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white50,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white40,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

