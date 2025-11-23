import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/goal_config.dart';
import '../services/storage_service.dart';

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.getInstance();
});

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final Ref ref;

  UserNotifier(this.ref) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = await ref.read(storageServiceProvider.future);
    final savedUser = storage.getUser();
    
    // If no user exists, create a default one for testing
    if (savedUser == null) {
      state = UserModel(
        name: 'Demo User',
        age: 28,
        weight: 185.0,
        targetWeight: 175.0,
        goalMode: GoalMode.cut,
        equipmentMode: EquipmentMode.bodyweight,
      );
    } else {
      state = savedUser;
    }
  }

  Future<void> updateUser(UserModel user) async {
    state = user;
    final storage = await ref.read(storageServiceProvider.future);
    await storage.saveUser(user);
  }

  Future<void> updateGoal(GoalMode goal) async {
    if (state != null) {
      final updated = state!.copyWith(goalMode: goal);
      await updateUser(updated);
    }
  }

  Future<void> updateEquipment(EquipmentMode equipment) async {
    if (state != null) {
      final updated = state!.copyWith(equipmentMode: equipment);
      await updateUser(updated);
    }
  }

  Future<void> updateWeight(double weight) async {
    if (state != null) {
      final updated = state!.copyWith(weight: weight);
      await updateUser(updated);
    }
  }

  Future<void> logout() async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.clearUser();
    state = null;
  }
}

