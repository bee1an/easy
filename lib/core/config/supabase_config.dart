/// Supabase Configuration
///
/// ⚠️ IMPORTANT: For Widget cloud sync to work with SideStore installs,
/// you MUST fill in your Supabase credentials below.
///
/// Setup steps:
/// 1. Go to https://supabase.com and create a free project
/// 2. Run the SQL from _internal/supabase_setup.sql in SQL Editor
/// 3. Get credentials from Settings → API
/// 4. Fill in the values below
class SupabaseConfig {
  // ========================================
  // 👇 SUPABASE CREDENTIALS
  // ========================================

  /// Your Supabase project URL
  static const String _hardcodedUrl =
      'https://ncjlkxrsobfdtqpuoqwt.supabase.co';

  /// Your Supabase anon/public key (safe to include in client code)
  static const String _hardcodedKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jamxreHJzb2JmZHRxcHVvcXd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMDgyODksImV4cCI6MjA4Mzg4NDI4OX0.oSelX276yN-CumrBpbrI1lY5BgSVhJQiER1BGVP8q8Y';

  // ========================================
  // 👆 END OF CONFIGURATION
  // ========================================

  /// Get Supabase URL (hardcoded takes priority over environment variable)
  static String get url {
    if (_hardcodedUrl.isNotEmpty) return _hardcodedUrl;
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  /// Get Supabase anon key
  static String get anonKey {
    if (_hardcodedKey.isNotEmpty) return _hardcodedKey;
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  /// Check if Supabase is configured
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
