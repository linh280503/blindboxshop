import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<domain.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign in failed: User is null');
    }

    final userModel = await remoteDataSource.getUserProfile(
      credential.user!.uid,
    );
    if (userModel == null) {
      throw Exception('User profile not found');
    }

    return UserMapper.toEntity(
      userModel,
      isEmailVerified: remoteDataSource.isEmailVerified,
    );
  }

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await remoteDataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) {
      throw Exception('Create user failed: User is null');
    }
    return credential.user!.uid;
  }

  @override
  Future<void> changePassword({required String currentPassword}) async {
    final user = remoteDataSource.currentUser;
    if (user == null) throw Exception('No user logged in');

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('User email is missing');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Re-authenticate to verify current password
    await user.reauthenticateWithCredential(credential);

    // Send password reset email
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    await remoteDataSource.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await remoteDataSource.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
  }

  @override
  Future<String?> getIdToken() async {
    return await remoteDataSource.getIdToken();
  }

  @override
  String? get currentUserId => remoteDataSource.currentUserId;

  @override
  bool get isLoggedIn => remoteDataSource.isLoggedIn;

  @override
  bool get isEmailVerified => remoteDataSource.isEmailVerified;

  @override
  String? get currentUserEmail => remoteDataSource.currentUserEmail;

  @override
  String? get currentUserDisplayName => remoteDataSource.currentUserDisplayName;

  @override
  String? get currentUserPhotoURL => remoteDataSource.currentUserPhotoURL;

  @override
  Stream<String?> get onAuthStateChanged =>
      remoteDataSource.authStateChanges.map((user) => user?.uid);

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? avatar,
  }) async {
    await remoteDataSource.createUserProfile(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
    );
  }

  @override
  Future<domain.User?> getUserProfile(String uid) async {
    final model = await remoteDataSource.getUserProfile(uid);
    return model != null
        ? UserMapper.toEntity(
            model,
            isEmailVerified: remoteDataSource.isEmailVerified,
          )
        : null;
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await remoteDataSource.updateUserProfile(uid, data);
  }

  @override
  Stream<domain.User?> watchUserProfile(String uid) {
    return remoteDataSource.watchUserProfile(uid).map((model) {
      return model != null
          ? UserMapper.toEntity(
              model,
              isEmailVerified: remoteDataSource.isEmailVerified,
            )
          : null;
    });
  }
}
