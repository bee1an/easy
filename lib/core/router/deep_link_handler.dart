import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/timer_provider.dart';

/// Handles deep links for the app
class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle links when app is in foreground or background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('DeepLink: Received uri: $uri');
      _handleUri(uri);
    });

    // Handle link that opened the app
    // Use addPostFrameCallback to ensure UI is ready before processing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialLink();
    });
  }

  Future<void> _checkInitialLink() async {
    // Small delay to ensure providers are fully initialized
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null && mounted) {
        debugPrint('DeepLink: Initial uri: $uri');
        _handleUri(uri);
      }
    } catch (e) {
      debugPrint('DeepLink: Error getting initial link: $e');
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'easy' && uri.host == 'start') {
      final timerProvider = context.read<TimerProvider>();
      if (!timerProvider.isRunning) {
        timerProvider.startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
