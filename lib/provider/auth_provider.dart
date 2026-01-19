import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy/service/cloud_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final CloudSyncService _cloudSync = CloudSyncService.instance;

  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  // Registration state
  String? _pendingEmail;
  String? _pendingPassword;

  /// Whether an auth operation is in progress
  bool get isLoading => _isLoading;

  /// Last error message
  String? get error => _error;

  /// Whether cloud sync is available
  bool get isCloudAvailable => _cloudSync.isAvailable;

  /// Whether user is logged in
  bool get isLoggedIn => _cloudSync.isLoggedIn;

  /// Current user ID
  String? get userId => _cloudSync.currentUserId;

  /// Current user email
  String? get userEmail => _cloudSync.currentUserEmail;

  /// Whether waiting for OTP verification during registration
  bool get isWaitingForOtp => _pendingEmail != null && _pendingPassword != null;

  /// Pending email for OTP verification
  String? get pendingEmail => _pendingEmail;

  /// Initialize and listen to auth changes
  Future<void> initialize() async {
    await _cloudSync.initialize();

    _authSubscription?.cancel();
    _authSubscription = _cloudSync.authStateChanges?.listen((state) {
      notifyListeners();
    });

    notifyListeners();
  }

  /// Sign in with email and password (existing user)
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cloudSync.signIn(email: email, password: password);

    _isLoading = false;
    if (!result.success) {
      _error = result.error;
    }
    notifyListeners();

    return result.success;
  }

  /// Start registration: send OTP to email
  Future<bool> startRegistration({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Send OTP to email
    final result = await _cloudSync.sendOtp(email: email);

    _isLoading = false;
    if (result.success) {
      _pendingEmail = email;
      _pendingPassword = password;
    } else {
      _error = result.error;
    }
    notifyListeners();

    return result.success;
  }

  /// Complete registration: verify OTP and create account
  Future<bool> completeRegistration({required String code}) async {
    if (_pendingEmail == null || _pendingPassword == null) {
      _error = '请先输入邮箱和密码';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Verify OTP
    final otpResult = await _cloudSync.verifyOtp(
      email: _pendingEmail!,
      token: code,
    );

    if (!otpResult.success) {
      _isLoading = false;
      _error = otpResult.error;
      notifyListeners();
      return false;
    }

    // OTP verified, now the user is logged in via OTP
    // We need to update their password
    final updateResult = await _cloudSync.updatePassword(_pendingPassword!);

    _isLoading = false;
    if (updateResult.success) {
      _pendingEmail = null;
      _pendingPassword = null;
    } else {
      _error = updateResult.error;
    }
    notifyListeners();

    return updateResult.success;
  }

  /// Cancel registration and go back
  void cancelRegistration() {
    _pendingEmail = null;
    _pendingPassword = null;
    _error = null;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _cloudSync.signOut();

    _isLoading = false;
    _error = null;
    _pendingEmail = null;
    _pendingPassword = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _cloudSync.resetPasswordForEmail(email: email);

    _isLoading = false;
    if (!result.success) {
      _error = result.error;
    }
    notifyListeners();

    return result.success;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
