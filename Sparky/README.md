# Flat Headset signing and anisette endpoint selection

Based on xtool 1.24.0, 70e1568fdfcb20b560774057cd783f02361293b9 (MIT, Kabir Oberai).
This change does not use an account, sign or install anything by itself.

Build on Linux with the release's Swift toolchain and native dependencies, using `swift build --build-system native --product xtool -j 4` after resolving the committed Package.resolved.
`xtool sparky-policy` prints `sparky-shared-pairing-1` and the selected anisette URL without network or account access.
`XTL_ANISETTE_URL=http://127.0.0.1:6969 xtool sparky-policy --probe` requests only `/v3/client_info`.
A metadata response does not establish usable anisette headers, provisioning or authentication.
The override must be an HTTPS origin, or HTTP on a literal loopback address; credentials, query parameters and subpaths are refused.
The default remains the upstream `https://mac-ani.jkcoxson.com` service and is displayed before an account prompt.
Changing endpoints invalidates saved anisette provisioning and authentication association.
The V3 finish request forwards Apple's routing value as well as ptm/tk for a local macOS ADI backend.

Only an IPA whose original ID is `org.sparkyos.flatheadset` gains a second keychain group.
The group is KDE Connect's default group, formed from the returned profile's application-ID prefix and the same account's xtool mapping of `org.sparkyos.kdeconnect`.
The returned profile must allow both exact groups or its own prefix wildcard; otherwise provisioning fails before signing.
No arbitrary wildcard becomes an app entitlement, no App Group is created, and Cardboard receives no access to pairing keys.
KDE Connect keeps its existing default group, so existing pairing material is not migrated or copied.
The receiver itself treats those records as read-only; the keychain entitlement grants group access, not an OS-enforced read-only permission.

`POLICY_TEST_OUTPUT=/an/output/path bash Sparky/check-policy.sh` runs Foundation-only policy checks and parses the changed Swift files on Linux without an SDK or account.
A full package build is a separate check.
A real profile and phone are required to verify Apple-issued permissions, key export and cross-app access.

On the tested Debian container, the Swift 6.4.1 Ubuntu 22.04 distribution also needed its libxml2.so.2 and ICU 72 runtime ABI; these were supplied privately for the toolchain, not installed on the host.
Its default `swiftbuild` engine crashed during planning before compiling xtool; the documented `--build-system native` engine is the alternate build check.
Neither incident is evidence about signing or authentication.

The local metadata probe also exercises a correction to upstream HTTPClientProtocol.send: an authority containing a port must be parsed as an origin, not assigned directly to URLComponents.host.
The V3 finish message uses exact dictionary keys because the existing snake-case encoder rewrites the required routing header name.
No credentials or provisioning data are used by the metadata fixture.

Run `python3 Sparky/test_endpoint.py /path/to/built/xtool` inside an isolated `--network none` container.
It starts an authored loopback fixture, verifies that the compiled client requests only `/v3/client_info` there, then checks that a cleartext non-loopback URL is refused.
It is not a real anisette provider or a provisioning test.
