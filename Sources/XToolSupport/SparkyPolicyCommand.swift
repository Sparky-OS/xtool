// SPDX-License-Identifier: MIT
import Foundation
import ArgumentParser
import XKit

struct SparkyPolicyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "sparky-policy",
        abstract: "Print the shared-pairing signing policy and selected anisette endpoint; no account or network")
    @Flag(help: "Fetch service metadata only; no account, provisioning or device access")
    var probe = false
    func run() async throws {
        let url = try SparkySigningPolicy.anisetteURL(ProcessInfo.processInfo.environment["XTL_ANISETTE_URL"])
        print(SparkySigningPolicy.version)
        print("Anisette endpoint: \(url.absoluteString)")
        if probe {
            let info = try await ADIDataProvider.probeEndpoint()
            guard !info.clientInfo.isEmpty, !info.akdUserAgent.isEmpty else {
                throw ValidationError("Anisette service returned empty metadata")
            }
            print("Anisette metadata answered (not a provisioning or authentication proof)")
        }
    }
}
