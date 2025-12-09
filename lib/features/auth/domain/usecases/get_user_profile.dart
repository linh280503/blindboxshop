import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case to get user profile
class GetUserProfile implements UseCase<User?, String> {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<User?> call(String uid) async {
    return await repository.getUserProfile(uid);
  }
}
