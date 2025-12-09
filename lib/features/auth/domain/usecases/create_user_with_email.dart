import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Parameters for CreateUserWithEmail use case
class CreateUserWithEmailParams {
  final String email;
  final String password;

  CreateUserWithEmailParams({required this.email, required this.password});
}

/// Use case to create user with email and password
class CreateUserWithEmail
    implements UseCase<String, CreateUserWithEmailParams> {
  final AuthRepository repository;

  CreateUserWithEmail(this.repository);

  @override
  Future<String> call(CreateUserWithEmailParams params) async {
    return await repository.createUserWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
