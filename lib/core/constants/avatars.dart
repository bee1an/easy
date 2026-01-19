/// Default avatar assets for user profiles
///
/// Users can only select from these pre-defined avatars.
/// This reduces storage pressure and simplifies implementation.
///
/// ## Adding New Avatars
/// 1. Add PNG file to `assets/avatars/` with naming: `avatar_XX.png` (e.g., avatar_09.png)
/// 2. Update [count] constant below to match the total number of avatars
/// 3. Run `flutter pub get` to refresh assets
class Avatars {
  Avatars._();

  /// Total number of available avatars
  /// Update this when adding new avatar files
  static const int count = 8;

  /// Default avatar index for new users
  static const int defaultIndex = 0;

  /// Asset directory path
  static const String _directory = 'assets/avatars';

  /// Get avatar path by index (with bounds check)
  /// Returns path in format: assets/avatars/avatar_XX.png
  static String getPath(int? index) {
    final safeIndex = (index ?? defaultIndex).clamp(0, count - 1);
    // Index 0 -> avatar_01.png, Index 1 -> avatar_02.png, etc.
    final number = (safeIndex + 1).toString().padLeft(2, '0');
    return '$_directory/avatar_$number.png';
  }

  /// Check if index is valid
  static bool isValidIndex(int index) => index >= 0 && index < count;

  /// Get all avatar paths (for preloading if needed)
  static List<String> get allPaths =>
      List.generate(count, (index) => getPath(index));
}
