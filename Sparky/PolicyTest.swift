// SPDX-License-Identifier: MIT
import Foundation
@main struct PolicyTest {
    static func main() throws {
        func denied(_ body: () throws -> Void) { do { try body(); fatalError("Expected refusal") } catch {} }
        func check(_ value: Bool) { precondition(value) }
        let app = "XTL-TEAM.org.sparkyos.flatheadset", kde = "XTL-TEAM.org.sparkyos.kdeconnect"
        let own = "PREFIX." + app, shared = "PREFIX." + kde
        func groups(_ allowed: [String], _ id: String = "org.sparkyos.flatheadset", _ profile: String? = nil) throws -> [String]? {
            try SparkySigningPolicy.groups(originalID:id,newID:app,kdeID:kde,applicationID:profile ?? own,allowed:allowed)
        }
        check(try groups(["PREFIX.*"]) == [own,shared])
        check(try groups([own,shared]) == [own,shared])
        check(try groups([], "org.sparkyos.cardboard") == nil)
        check(try groups([], "org.sparkyos.kdeconnect") == nil)
        denied { _ = try groups([own]) }
        denied { _ = try groups(["OTHER.*"]) }
        denied { _ = try groups(["*"]) }
        denied { _ = try groups(["PREFIX.*"], "org.sparkyos.flatheadset", "PREFIX.evil") }
        check(try SparkySigningPolicy.anisetteURL(nil).absoluteString == "https://mac-ani.jkcoxson.com")
        check(try SparkySigningPolicy.anisetteURL("http://127.0.0.1:6969").host == "127.0.0.1")
        for bad in ["http://example.org", "https://user:pass@example.org", "http://127.0.0.1:6969/?secret=x", "file:///tmp/ani", "https://example.org/v3"] {
            denied { _ = try SparkySigningPolicy.anisetteURL(bad) }
        }
        let finish = try SparkySigningPolicy.finishProvisioningMessage(ptm: Data([1]), tk: Data([2]), routingInfo: 123)
        let fields = try JSONSerialization.jsonObject(with: Data(finish.utf8)) as? [String:String]
        precondition(fields == ["ptm":"AQ==", "tk":"Ag==", "X-Apple-I-MD-RINFO":"123"])
        print("PASS: own group stays first; only receiver shares; exact/prefix-wildcard profile accepted; missing/wrong profile denied; endpoint validation; exact V3 routing field")
    }
}
