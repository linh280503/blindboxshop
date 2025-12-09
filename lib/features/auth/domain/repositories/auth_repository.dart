import '../entities/user.dart' as domain;

abstract class AuthRepository {
  // Auth operations
  Future<domain.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> changePassword({required String currentPassword});

  Future<void> signOut();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updateProfile({String? displayName, String? photoURL});

  Future<void> deleteAccount();

  Future<String?> getIdToken();

  // Current user info
  String? get currentUserId;
  bool get isLoggedIn;
  bool get isEmailVerified;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  String? get currentUserPhotoURL;

  // Streams
  Stream<String?> get onAuthStateChanged;

  // User profile operations
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? avatar,
  });

  Future<domain.User?> getUserProfile(String uid);

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);

  Stream<domain.User?> watchUserProfile(String uid);
}
