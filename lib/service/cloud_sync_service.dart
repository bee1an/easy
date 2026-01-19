import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/model/bristol_scale.dart';
import 'package:easy/model/poop_color.dart';
import 'package:easy/core/config/supabase_config.dart';

/// Cloud sync service using Supabase
class CloudSyncService {
  static CloudSyncService? _instance;
  static CloudSyncService get instance => _instance ??= CloudSyncService._();

  CloudSyncService._();

  bool _initialized = false;

  /// Initialize Supabase
  Future<void> initialize() async {
    if (_initialized || !SupabaseConfig.isConfigured) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _initialized = true;
      debugPrint('CloudSyncService: Supabase initialized');
    } catch (e) {
      debugPrint('CloudSyncService: Failed to initialize Supabase: $e');
    }
  }

  /// Get Supabase client
  SupabaseClient? get _client {
    if (!_initialized || !SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  /// Check if cloud sync is available
  bool get isAvailable => _initialized && SupabaseConfig.isConfigured;

  /// Check if user is logged in
  bool get isLoggedIn => _client?.auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _client?.auth.currentUser?.id;

  /// Get current user email
  String? get currentUserEmail => _client?.auth.currentUser?.email;

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      return AuthResult.failure('Cloud sync not configured');
    }

    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(response.user!.id);
      } else {
        return AuthResult.failure('Registration failed');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Unknown error: $e');
    }
  }

  /// Send OTP code to email for sign up / sign in
  Future<AuthResult> sendOtp({required String email}) async {
    if (_client == null) {
      return AuthResult.failure('云同步未配置');
    }

    try {
      await _client!.auth.signInWithOtp(email: email, shouldCreateUser: true);
      return AuthResult.success('');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('发送验证码失败: $e');
    }
  }

  /// Verify OTP code
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
  }) async {
    if (_client == null) {
      return AuthResult.failure('云同步未配置');
    }

    try {
      final response = await _client!.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        return AuthResult.success(response.user!.id);
      } else {
        return AuthResult.failure('验证失败');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('验证失败: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      return AuthResult.failure('云同步未配置');
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(response.user!.id);
      } else {
        return AuthResult.failure('登录失败');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('登录失败: $e');
    }
  }

  /// Update user password (used after OTP verification during registration)
  Future<AuthResult> updatePassword(String password) async {
    if (_client == null) {
      return AuthResult.failure('云同步未配置');
    }

    try {
      await _client!.auth.updateUser(UserAttributes(password: password));
      return AuthResult.success('');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('设置密码失败: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> resetPasswordForEmail({required String email}) async {
    if (_client == null) {
      return AuthResult.failure('云同步未配置');
    }

    try {
      await _client!.auth.resetPasswordForEmail(email);
      return AuthResult.success('');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('发送重置邮件失败: $e');
    }
  }

  /// Sync a single record to cloud
  Future<bool> syncRecord(PoopRecord record) async {
    if (_client == null || !isLoggedIn) return false;

    try {
      await _client!.from('poop_records').upsert({
        'id': record.id,
        'user_id': currentUserId,
        'start_time': record.startTime.toIso8601String(),
        'end_time': record.endTime.toIso8601String(),
        'poop_color': record.poopColor.index,
        'custom_color': record.customColor,
        'bristol_scale': record.bristolScale.index,
        'custom_type': record.customType,
        'amount': record.amount.index,
        'custom_amount': record.customAmount,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('CloudSyncService: Failed to sync record: $e');
      return false;
    }
  }

  /// Sync all records to cloud
  Future<int> syncAllRecords(List<PoopRecord> records) async {
    if (_client == null || !isLoggedIn) return 0;

    int successCount = 0;
    for (final record in records) {
      if (await syncRecord(record)) {
        successCount++;
      }
    }
    return successCount;
  }

  /// Delete a record from cloud
  Future<bool> deleteRecord(String recordId) async {
    if (_client == null || !isLoggedIn) return false;

    try {
      await _client!
          .from('poop_records')
          .delete()
          .eq('id', recordId)
          .eq('user_id', currentUserId!);
      return true;
    } catch (e) {
      debugPrint('CloudSyncService: Failed to delete record: $e');
      return false;
    }
  }

  /// Fetch all records from cloud
  /// If [userId] is provided, fetches records for that user (requires mutual follow)
  /// Otherwise fetches current user's records
  Future<List<PoopRecord>> fetchRecords({String? userId}) async {
    if (_client == null || !isLoggedIn) return [];

    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) return [];

    try {
      final response = await _client!
          .from('poop_records')
          .select()
          .eq('user_id', targetUserId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => _recordFromCloudJson(json))
          .toList();
    } catch (e) {
      debugPrint('CloudSyncService: Failed to fetch records: $e');
      return [];
    }
  }

  /// Get widget stats for current user
  /// Returns data for Widget to display
  Future<Map<String, dynamic>?> getWidgetStats() async {
    if (_client == null || !isLoggedIn) return null;

    try {
      final response = await _client!.rpc(
        'get_widget_stats',
        params: {'p_user_id': currentUserId},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('CloudSyncService: Failed to get widget stats: $e');
      return null;
    }
  }

  /// Convert cloud JSON to PoopRecord
  PoopRecord _recordFromCloudJson(Map<String, dynamic> json) {
    return PoopRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      poopColor: PoopColor.values[json['poop_color'] as int? ?? 0],
      customColor: json['custom_color'] as String?,
      bristolScale: BristolScale.values[json['bristol_scale'] as int],
      customType: json['custom_type'] as String?,
      amount: PoopAmount.values[json['amount'] as int],
      customAmount: json['custom_amount'] as String?,
    );
  }

  /// Listen to auth state changes
  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;
}

/// Result of authentication operations
class AuthResult {
  final bool success;
  final String? userId;
  final String? error;

  AuthResult._({required this.success, this.userId, this.error});

  factory AuthResult.success(String userId) =>
      AuthResult._(success: true, userId: userId);

  factory AuthResult.failure(String error) =>
      AuthResult._(success: false, error: error);
}
