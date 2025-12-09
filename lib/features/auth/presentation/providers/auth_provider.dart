import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../data/di/auth_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/create_user_with_email.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../../../core/services/notification_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final signInWithEmail = ref.watch(signInWithEmailProvider);
  final createUserWithEmail = ref.watch(createUserWithEmailProvider);
  final getUserProfile = ref.watch(getUserProfileProvider);
  return AuthNotifier(
    repository: repo,
    signInWithEmailUC: signInWithEmail,
    createUserWithEmailUC: createUserWithEmail,
    getUserProfileUC: getUserProfile,
  );
});

final userProfileProvider = FutureProvider.family<User?, String>((
  ref,
  uid,
) async {
  final getUserProfile = ref.watch(getUserProfileProvider);
  return await getUserProfile(uid);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SignInWithEmail signInWithEmailUC;
  final CreateUserWithEmail createUserWithEmailUC;
  final GetUserProfile getUserProfileUC;

  StreamSubscription<String?>? _authStateSubscription;
  StreamSubscription<User?>? _userProfileSubscription;

  AuthNotifier({
    required this.repository,
    required this.signInWithEmailUC,
    required this.createUserWithEmailUC,
    required this.getUserProfileUC,
  }) : super(AuthState()) {
    _init();
  }

  void _init() {
    _authStateSubscription = repository.onAuthStateChanged.listen((
      String? uid,
    ) {
      _userProfileSubscription?.cancel();
      if (uid != null) {
        _subscribeToUserProfile(uid);
      } else {
        state = state.copyWith(user: null);
      }
    });
  }

  void _subscribeToUserProfile(String uid) {
    state = state.copyWith(isLoading: true, error: null);
    _userProfileSubscription = repository
        .watchUserProfile(uid)
        .listen(
          (userEntity) {
            if (userEntity != null) {
              state = state.copyWith(user: userEntity, isLoading: false);
            } else {
              state = state.copyWith(user: null, isLoading: false);
            }
          },
          onError: (e) {
            state = state.copyWith(
              user: null,
              isLoading: false,
              error: e.toString(),
            );
          },
        );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await signInWithEmailUC(
        SignInWithEmailParams(email: email, password: password),
      );

      // Kiểm tra email verification
      if (!repository.isEmailVerified) {
        await repository.signOut();
        state = state.copyWith(
          isLoading: false,
          error: 'Email chưa được xác thực',
        );
        throw 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư của bạn.';
      }

      state = state.copyWith(user: user, isLoading: false);
      NotificationService.showSuccess('Đăng nhập thành công!');
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    }
  }

  String _getErrorMessage(dynamic error) {
    final e = error.toString();
    if (e.contains('user-not-found') || e.contains('invalid-credential')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }
    if (e.contains('wrong-password')) {
      return 'Mật khẩu không chính xác.';
    }
    if (e.contains('invalid-email')) {
      return 'Email không hợp lệ.';
    }
    if (e.contains('user-disabled')) {
      return 'Tài khoản đã bị vô hiệu hóa.';
    }
    if (e.contains('too-many-requests')) {
      return 'Quá nhiều yêu cầu đăng nhập. Vui lòng thử lại sau.';
    }
    if (e.contains('Email chưa được xác thực')) {
      return 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư của bạn.';
    }
    if (e.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.';
    }
    return 'Đã có lỗi xảy ra: $error';
  }

  // Đăng ký với email và password
  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final uid = await createUserWithEmailUC(
        CreateUserWithEmailParams(email: email, password: password),
      );

      // Tạo profile trong Firestore
      await repository.createUserProfile(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
      );

      // Gửi email xác thực
      await repository.sendEmailVerification();

      // Đăng xuất ngay lập tức để người dùng phải đăng nhập lại sau khi verify
      await repository.signOut();

      NotificationService.showSuccess(
        'Tạo tài khoản thành công! Vui lòng kiểm tra email để xác thực.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Tạo tài khoản thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await repository.signOut();
      state = AuthState();
      NotificationService.showInfo('Đã đăng xuất thành công!');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      NotificationService.showError('Đăng xuất thất bại: ${e.toString()}');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    try {
      if (state.user == null) return false;

      state = state.copyWith(isLoading: true, error: null);

      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (phone != null) updateData['phone'] = phone.trim();
      if (avatar != null) updateData['avatar'] = avatar;

      if (updateData.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true; // Không có gì để cập nhật nhưng coi như thành công
      }

      await repository.updateUserProfile(state.user!.uid, updateData);
      // await _loadUserProfile(state.user!.uid); // Stream will update this automatically
      NotificationService.showSuccess('Cập nhật thông tin thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError(
        'Cập nhật thông tin thất bại: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword) async {
    try {
      if (state.user == null) return false;

      state = state.copyWith(isLoading: true, error: null);

      await repository.changePassword(currentPassword: currentPassword);

      state = state.copyWith(isLoading: false);
      NotificationService.showSuccess(
        'Đã gửi email đổi mật khẩu. Vui lòng kiểm tra hộp thư!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Đổi mật khẩu thất bại: ${e.toString()}');
      return false;
    }
  }

  // Reset password (Gửi email reset link)
  Future<bool> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await repository.sendPasswordResetEmail(email);

      state = state.copyWith(isLoading: false);
      NotificationService.showSuccess('Đã gửi email reset mật khẩu!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError(
        'Gửi email reset mật khẩu thất bại: ${e.toString()}',
      );
      return false;
    }
  }

  // Gửi lại email xác thực
  Future<bool> resendVerificationEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Cần đăng nhập lại để lấy user object và gửi email
      final user = await signInWithEmailUC(
        SignInWithEmailParams(email: email, password: password),
      );

      await repository.sendEmailVerification();
      await repository.signOut();

      state = state.copyWith(isLoading: false);
      NotificationService.showSuccess('Đã gửi lại email xác thực!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Gửi lại email thất bại: ${e.toString()}');
      return false;
    }
  }
}
