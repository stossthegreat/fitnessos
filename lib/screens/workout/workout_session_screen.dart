import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_template.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import 'camera_workout_screen.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate template;
  
  const WorkoutSessionScreen({super.key, required this.template});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  final Map<String, List<Map<String, dynamic>>> _completedSets = {};
  
  @override
  Widget build(BuildContext context) {
    final exercises = widget.template.exercises;
    
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
          title: Text(widget.template.name),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () {
                // Show workout summary
              },
              icon: const Icon(Icons.check_circle_outline),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final isCurrentExercise = index == _currentExerciseIndex;
            final isPastExercise = index < _currentExerciseIndex;
            final completedSets = _completedSets[exercise.exerciseId] ?? [];
            
            return _buildExerciseCard(
              exercise,
              index + 1,
              isCurrentExercise: isCurrentExercise,
              isPastExercise: isPastExercise,
              completedSets: completedSets,
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildExerciseCard(
    WorkoutExercise exercise,
    int number,
    {
      required bool isCurrentExercise,
      required bool isPastExercise,
      required List<Map<String, dynamic>> completedSets,
    }
  ) {
    final allSetsComplete = completedSets.length >= exercise.sets;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isCurrentExercise
              ? [AppColors.amber400.withOpacity(0.2), AppColors.amber400.withOpacity(0.1)]
              : [AppColors.slate900, AppColors.slate950],
        ),
        border: Border.all(
          color: isCurrentExercise
              ? AppColors.amber400
              : AppColors.white10,
          width: isCurrentExercise ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: allSetsComplete
                      ? AppColors.emerald400
                      : isCurrentExercise
                          ? AppColors.amber400
                          : AppColors.white20,
                ),
                child: Center(
                  child: Text(
                    allSetsComplete ? '✓' : '$number',
                    style: TextStyle(
                      color: allSetsComplete || isCurrentExercise
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: AppTextStyles.h4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${exercise.sets} sets × ${exercise.reps} reps',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white70,
            ),
          ),
          if (exercise.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              exercise.notes!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white50,
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Sets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(exercise.sets, (setIndex) {
              final isComplete = setIndex < completedSets.length;
              final isCurrent = setIndex == completedSets.length && isCurrentExercise;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isComplete
                      ? AppColors.emerald400.withOpacity(0.2)
                      : isCurrent
                          ? AppColors.amber400.withOpacity(0.2)
                          : AppColors.white10,
                  border: Border.all(
                    color: isComplete
                        ? AppColors.emerald400
                        : isCurrent
                            ? AppColors.amber400
                            : AppColors.white20,
                  ),
                ),
                child: Text(
                  isComplete
                      ? 'Set ${setIndex + 1}: ${completedSets[setIndex]['reps']} reps'
                      : 'Set ${setIndex + 1}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isComplete || isCurrent ? Colors.white : AppColors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
          
          if (isCurrentExercise && !allSetsComplete) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to camera workout screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraWorkoutScreen(
                        exercise: exercise,
                        setNumber: completedSets.length + 1,
                      ),
                    ),
                  );
                  
                  if (result != null) {
                    setState(() {
                      _completedSets[exercise.exerciseId] = [
                        ...(_completedSets[exercise.exerciseId] ?? []),
                        result,
                      ];
                      
                      // Move to next exercise if all sets complete
                      if ((_completedSets[exercise.exerciseId]?.length ?? 0) >= exercise.sets) {
                        if (_currentExerciseIndex < widget.template.exercises.length - 1) {
                          _currentExerciseIndex++;
                        }
                      }
                    });
                  }
                },
                child: Text('START SET ${completedSets.length + 1}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
