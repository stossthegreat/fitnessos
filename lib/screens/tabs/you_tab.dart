import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_config.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

class YouTab extends ConsumerWidget {
  const YouTab({super.key});

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
    final projectedChange = goal.projectionDelta;
    final projectedWeight = (user.weight + projectedChange).toStringAsFixed(1);

    final personas = [
      {'name': 'Tactical Instructor', 'icon': Icons.track_changes, 'active': true},
      {'name': 'Drill Sergeant', 'icon': Icons.dangerous, 'active': false},
      {'name': 'Calm Coach', 'icon': Icons.favorite, 'active': false},
      {'name': 'Future You', 'icon': Icons.trending_up, 'active': false},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You', style: AppTextStyles.h1),
          const SizedBox(height: 24),

          // Projection
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.emeraldGradient,
              ),
              border: Border.all(color: AppColors.emerald500.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald400.withOpacity(0.2),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIX WEEKS FROM NOW',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.emerald300.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${projectedChange > 0 ? "+" : ""}$projectedChange lbs',
                  style: AppTextStyles.display1.copyWith(fontSize: 52),
                ),
                const SizedBox(height: 8),
                Text(
                  'On your current path (${goal.short}), you will weigh $projectedWeight pounds.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.black30,
                    border: Border.all(color: AppColors.emerald400.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Goal focus', goal.label),
                      const SizedBox(height: 8),
                      _buildStatRow('Assumed compliance', '~70% of days'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.emerald400,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Drop compliance to 60% and the change slows by roughly a third. The OS will warn you long before the mirror does.',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Your Council
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COUNCIL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: personas.length,
                  itemBuilder: (context, index) {
                    final persona = personas[index];
                    final isActive = persona['active'] as bool;

                    return InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [AppColors.slate900, AppColors.slate800],
                          ),
                          border: Border.all(
                            color: isActive
                                ? AppColors.amber400.withOpacity(0.4)
                                : AppColors.slate500.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              persona['icon'] as IconData,
                              color: isActive
                                  ? AppColors.amber400
                                  : AppColors.slate400,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              persona['name'] as String,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Active',
                                style: AppTextStyles.labelTiny.copyWith(
                                  color: AppColors.amber400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekend Pattern
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
                  Text(
                    'Weekend pattern',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.rose300,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your binge cycle starts Thursday.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.rose300.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Historical success rate: 33%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.rose300.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.rose400,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Three interventions that worked:',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.rose300.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBulletPoint('High-protein Friday dinner'),
                        _buildBulletPoint('Saturday morning session'),
                        _buildBulletPoint('No delivery apps after 6pm'),
                      ],
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 24),

          // This Week Stats
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
                _buildStatRow(
                  'Weight',
                  '${user.weight.toStringAsFixed(0)} → $projectedWeight pounds',
                ),
                const SizedBox(height: 12),
                _buildStatRow('Compliance (current)', '${user.compliance}%'),
                const SizedBox(height: 12),
                _buildStatRow('Sessions', '3 of 5 completed'),
                const SizedBox(height: 12),
                _buildStatRow('Sleep', '6.1 hours average'),
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

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white70,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.rose300.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.rose300.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

