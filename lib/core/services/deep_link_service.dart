import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service to handle deep links for the app.
/// Supports invite links: stallio://invite?token=xxx or https://app.stallio.co.uk/invite?token=xxx
///
/// TODO: Configure platform-specific deep link handling:
///
/// **Android** - Add to `android/app/src/main/AndroidManifest.xml` inside <activity>:
/// ```xml
/// <intent-filter android:autoVerify="true">
///   <action android:name="android.intent.action.VIEW" />
///   <category android:name="android.intent.category.DEFAULT" />
///   <category android:name="android.intent.category.BROWSABLE" />
///   <data android:scheme="stallio" />
///   <data android:scheme="https" android:host="app.stallio.co.uk" />
/// </intent-filter>
/// ```
///
/// **iOS** - Add to `ios/Runner/Info.plist`:
/// ```xml
/// <key>CFBundleURLTypes</key>
/// <array>
///   <dict>
///     <key>CFBundleURLSchemes</key>
///     <array>
///       <string>stallio</string>
///     </array>
///   </dict>
/// </array>
/// <key>FlutterDeepLinkingEnabled</key>
/// <true/>
/// ```
/// Also configure Associated Domains in Xcode for Universal Links.
///
/// **Web** - Create landing page at app.stallio.co.uk/invite that:
/// 1. Checks if app is installed (via custom scheme redirect)
/// 2. Falls back to web app or app store links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  final _inviteTokenController = StreamController<String>.broadcast();

  /// Stream of invite tokens received via deep links
  Stream<String> get inviteTokenStream => _inviteTokenController.stream;

  /// The pending invite token (if app was opened via invite link)
  String? _pendingInviteToken;
  String? get pendingInviteToken => _pendingInviteToken;

  /// Clear the pending invite token after it's been handled
  void clearPendingInviteToken() {
    _pendingInviteToken = null;
  }

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle initial link (app opened via link)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // Handle links while app is running
    _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (e) => debugPrint('Deep link error: $e'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    // Check if it's an invite link
    // Supports: stallio://invite?token=xxx or https://app.stallio.co.uk/invite?token=xxx
    if (uri.path == '/invite' || uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        _pendingInviteToken = token;
        _inviteTokenController.add(token);
        debugPrint('Invite token received: $token');
      }
    }
  }

  void dispose() {
    _inviteTokenController.close();
  }
}
