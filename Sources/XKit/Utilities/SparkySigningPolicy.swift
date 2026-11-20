// SPDX-License-Identifier: MIT
import Foundation

// Only our receiver borrows KDE Connect's default keychain group. Never grant
// arbitrary groups supplied by an IPA or derive permissions from the team alone.
public enum SparkySigningPolicy {
    public static let version = "sparky-shared-pairing-1"
    public enum Failure: Error { case invalidProfile, groupNotProvisioned, invalidAnisetteURL }

    public static func groups(originalID: String, newID: String, kdeID: String,
                              applicationID: String, allowed: [String]) throws -> [String]? {
        guard originalID == "org.sparkyos.flatheadset" else { return nil }
        guard applicationID.hasSuffix("." + newID) else { throw Failure.invalidProfile }
        let prefix = String(applicationID.dropLast(newID.count + 1))
        guard !prefix.isEmpty, !prefix.contains("."), !prefix.contains("*"),
              kdeID.hasSuffix(".org.sparkyos.kdeconnect") else { throw Failure.invalidProfile }
        let result = [applicationID, prefix + "." + kdeID]
        for group in result {
            guard allowed.contains(group) || allowed.contains(prefix + ".*") else {
                throw Failure.groupNotProvisioned
            }
        }
        return result
    }

    public static func finishProvisioningMessage(ptm: Data, tk: Data, routingInfo: UInt64) throws -> String {
        // The provider's snake-case encoder would corrupt this header-shaped key.
        let fields = ["ptm": ptm.base64EncodedString(), "tk": tk.base64EncodedString(),
                      "X-Apple-I-MD-RINFO": String(routingInfo)]
        return String(decoding: try JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys]), as: UTF8.self)
    }

    public static func anisetteURL(_ value: String?) throws -> URL {
        let source = value ?? "https://mac-ani.jkcoxson.com"
        guard let url = URL(string: source), let parts = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = parts.host, !host.isEmpty, parts.user == nil, parts.password == nil,
              parts.query == nil, parts.fragment == nil,
              parts.path.isEmpty || parts.path == "/",
              parts.scheme == "https" || (parts.scheme == "http" && ["127.0.0.1", "[::1]"].contains(host))
        else { throw Failure.invalidAnisetteURL }
        return url
    }
}
