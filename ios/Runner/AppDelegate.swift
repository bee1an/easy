import Flutter
import UIKit

private enum AppIdentity {
  static func ids() -> [String: Any] {
    let bundleId = Bundle.main.bundleIdentifier
    let profile = ProvisioningProfile.load()
    let teamId = profile?.teamId ?? profile?.applicationIdentifierTeamId
    let appId = profile?.applicationIdentifier ?? appIdentifier(teamId: teamId, bundleId: bundleId)
    let appGroups = profile?.appGroups ?? []
    let appGroupInfos: [[String: Any]] = appGroups.map { id in
      let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
      return [
        "id": id,
        "containerUrl": url?.path ?? NSNull(),
      ]
    }

    let payload: [String: Any] = [
      "teamId": teamId ?? NSNull(),
      "bundleId": bundleId ?? NSNull(),
      "appId": appId ?? NSNull(),
      "appGroups": appGroupInfos,
    ]
    return payload
  }

  private static func appIdentifier(teamId: String?, bundleId: String?) -> String? {
    guard let teamId, let bundleId else { return nil }
    return "\(teamId).\(bundleId)"
  }
}

private struct ProvisioningProfile {
  let teamId: String?
  let applicationIdentifier: String?
  let applicationIdentifierTeamId: String?
  let appGroups: [String]

  static func load() -> ProvisioningProfile? {
    guard let url = Bundle.main.url(
      forResource: "embedded",
      withExtension: "mobileprovision"
    ) else {
      return nil
    }
    guard let data = try? Data(contentsOf: url),
          let content = String(data: data, encoding: .isoLatin1) else {
      return nil
    }
    guard let plistRangeStart = content.range(of: "<plist"),
          let plistRangeEnd = content.range(of: "</plist>") else {
      return nil
    }
    let plistString = String(content[plistRangeStart.lowerBound..<plistRangeEnd.upperBound])
    guard let plistData = plistString.data(using: .utf8) else { return nil }
    guard let plist = try? PropertyListSerialization.propertyList(
      from: plistData,
      options: [],
      format: nil
    ) as? [String: Any] else {
      return nil
    }

    let entitlements = plist["Entitlements"] as? [String: Any]
    let entitlementsTeamId = entitlements?["com.apple.developer.team-identifier"] as? String
    let applicationIdentifier = entitlements?["application-identifier"] as? String
    let appGroups = entitlements?["com.apple.security.application-groups"] as? [String] ?? []
    let teamIdentifier = (plist["TeamIdentifier"] as? [String])?.first
    let appIdentifierPrefix = (plist["ApplicationIdentifierPrefix"] as? [String])?.first
    let inferredTeamId = entitlementsTeamId ?? teamIdentifier ?? appIdentifierPrefix
    let applicationIdentifierTeamId = applicationIdentifier?
      .split(separator: ".")
      .first
      .map(String.init)

    return ProvisioningProfile(
      teamId: inferredTeamId,
      applicationIdentifier: applicationIdentifier,
      applicationIdentifierTeamId: applicationIdentifierTeamId,
      appGroups: appGroups
    )
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "app_identity",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "getIds":
          result(AppIdentity.ids())
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
