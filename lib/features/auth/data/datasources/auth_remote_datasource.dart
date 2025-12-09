// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Abstract datasource for remote auth data
abstract class AuthRemoteDataSource {
  // Auth operations
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({String? displayName, String? photoURL});
  Future<void> deleteAccount();
  Future<String?> getIdToken();

  // Current user info
  User? get currentUser;
  String? get currentUserId;
  bool get isLoggedIn;
  bool get isEmailVerified;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  String? get currentUserPhotoURL;

  // Streams
  Stream<User?> get authStateChanges;

  // User profile operations
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? avatar,
  });
  Future<UserModel?> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
  Stream<UserModel?> watchUserProfile(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  static const String _usersCollection = 'users';

  AuthRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi đăng nhập: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi đăng ký: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Lỗi gửi email xác thực: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Lỗi gửi email reset password: $e');
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật profile: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Lỗi xóa tài khoản: $e');
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy token: $e');
    }
  }

  @override
  User? get currentUser => auth.currentUser;

  @override
  String? get currentUserId => auth.currentUser?.uid;

  @override
  bool get isLoggedIn => auth.currentUser != null;

  @override
  bool get isEmailVerified => auth.currentUser?.emailVerified ?? false;

  @override
  String? get currentUserEmail => auth.currentUser?.email;

  @override
  String? get currentUserDisplayName => auth.currentUser?.displayName;

  @override
  String? get currentUserPhotoURL => auth.currentUser?.photoURL;

  @override
  Stream<User?> get authStateChanges => auth.authStateChanges();

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? avatar,
  }) async {
    try {
      await firestore.collection(_usersCollection).doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'avatar': avatar ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'customer',
        'points': 0,
        'totalOrders': 0,
        'totalSpent': 0.0,
      });
    } catch (e) {
      throw Exception('Lỗi tạo hồ sơ người dùng: $e');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin người dùng: $e');
    }
  }

  @override
  Stream<UserModel?> watchUserProfile(String uid) {
    return firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
