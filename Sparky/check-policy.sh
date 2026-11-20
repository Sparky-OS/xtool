#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
: "${SWIFTC:=swiftc}"
: "${POLICY_TEST_OUTPUT:?Name an output path outside the source tree}"
"$SWIFTC" "$root/Sources/XKit/Utilities/SparkySigningPolicy.swift" "$root/Sparky/PolicyTest.swift" -o "$POLICY_TEST_OUTPUT"
"$POLICY_TEST_OUTPUT"
for file in \
 'Sources/XKit/DeveloperServices/App IDs/DeveloperServicesAddAppOperation.swift' \
 Sources/XKit/GrandSlam/Anisette/OmnisetteADIProvider.swift \
 Sources/XKit/GrandSlam/Anisette/ADIDataProvider.swift \
 Sources/XKit/HTTPClientProtocol/HTTPClientProtocol.swift \
 Sources/XToolSupport/AuthCommand.swift \
 Sources/XToolSupport/SparkyPolicyCommand.swift \
 Sources/XToolSupport/XTool.swift; do
    "$SWIFTC" -frontend -parse "$root/$file"
done
printf '%s\n' 'PASS: changed Swift files parse; full package type-check/build is separate'
