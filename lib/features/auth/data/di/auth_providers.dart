import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/auth_remote_datasource.dart';
import '../repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/create_user_with_email.dart';
import '../../domain/usecases/get_user_profile.dart';

// Datasource provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmail(repository);
});

final createUserWithEmailProvider = Provider<CreateUserWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CreateUserWithEmail(repository);
});

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetUserProfile(repository);
});
