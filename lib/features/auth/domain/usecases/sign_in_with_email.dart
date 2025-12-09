import '../entities/user.dart' as domain;
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Parameters for SignInWithEmail use case
class SignInWithEmailParams {
  final String email;
  final String password;

  SignInWithEmailParams({required this.email, required this.password});
}

/// Use case to sign in with email and password
class SignInWithEmail implements UseCase<domain.User, SignInWithEmailParams> {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<domain.User> call(SignInWithEmailParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
