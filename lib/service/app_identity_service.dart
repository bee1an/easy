import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppIdentity {
  final String? teamId;
  final String? bundleId;
  final String? appId;
  final List<AppGroupInfo> appGroups;
  final bool isSupported;
  final String? errorMessage;

  const AppIdentity({
    required this.teamId,
    required this.bundleId,
    required this.appId,
    required this.appGroups,
    required this.isSupported,
    required this.errorMessage,
  });

  const AppIdentity.unsupported()
      : teamId = null,
        bundleId = null,
        appId = null,
        appGroups = const [],
        isSupported = false,
        errorMessage = 'Unsupported platform';
}

class AppGroupInfo {
  final String id;
  final String? containerUrl;

  const AppGroupInfo({required this.id, required this.containerUrl});

  bool get isAvailable => containerUrl != null && containerUrl!.isNotEmpty;
}

class AppIdentityService {
  AppIdentityService._();

  static final AppIdentityService instance = AppIdentityService._();
  static const MethodChannel _channel = MethodChannel('app_identity');

  Future<AppIdentity> fetch() async {
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (!isIos) {
      return const AppIdentity.unsupported();
    }

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getIds');
      final rawGroups = result?['appGroups'] as List<dynamic>? ?? const [];
      final appGroups = rawGroups
          .map((group) {
            if (group is Map) {
              final id = group['id'] as String?;
              final containerUrl = group['containerUrl'];
              return AppGroupInfo(
                id: id ?? 'Unknown',
                containerUrl: containerUrl is String ? containerUrl : null,
              );
            }
            return null;
          })
          .whereType<AppGroupInfo>()
          .toList();
      return AppIdentity(
        teamId: result?['teamId'] as String?,
        bundleId: result?['bundleId'] as String?,
        appId: result?['appId'] as String?,
        appGroups: appGroups,
        isSupported: true,
        errorMessage: null,
      );
    } on PlatformException catch (error) {
      return AppIdentity(
        teamId: null,
        bundleId: null,
        appId: null,
        appGroups: const [],
        isSupported: true,
        errorMessage: error.message ?? 'Platform error',
      );
    } catch (error) {
      return AppIdentity(
        teamId: null,
        bundleId: null,
        appId: null,
        appGroups: const [],
        isSupported: true,
        errorMessage: error.toString(),
      );
    }
  }
}
