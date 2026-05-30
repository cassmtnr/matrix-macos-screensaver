#!/usr/bin/env bash
#
# Build, sign, notarize and staple MatrixDigitalRain.saver for distribution.
#
# Prerequisites (one-time setup):
#   1. A "Developer ID Application" certificate for team 58N4UVGANT installed
#      in the login keychain.
#   2. An App Store Connect API key (.p8) stored as a notarytool keychain
#      profile named "matrix-notary":
#
#        xcrun notarytool store-credentials "matrix-notary" \
#          --key ~/path/to/AuthKey_XXXXXXXX.p8 \
#          --key-id <KEY_ID> \
#          --issuer <ISSUER_ID>
#
# Output:
#   MatrixDigitalRain.saver.zip in the repo root, containing the stapled
#   .saver bundle, ready to attach to a GitHub Release.

set -euo pipefail

readonly PROJECT="MatrixDigitalRain.xcodeproj"
readonly SCHEME="MatrixDigitalRain"
readonly PRODUCT_NAME="MatrixDigitalRain.saver"
readonly BUILD_DIR="build"
readonly NOTARY_PROFILE="matrix-notary"

cd "$(dirname "$0")/.."

readonly PRODUCTS_DIR="${BUILD_DIR}/Build/Products/Release"
readonly SAVER_PATH="${PRODUCTS_DIR}/${PRODUCT_NAME}"
readonly NOTARY_ZIP="${PRODUCTS_DIR}/${PRODUCT_NAME}.zip"
readonly RELEASE_ZIP="${PRODUCT_NAME}.zip"

step() { printf "\n\033[1;32m==>\033[0m %s\n" "$1"; }

step "Cleaning and building Release"
xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}" \
    clean build

step "Verifying signature and hardened runtime"
codesign --verify --strict --verbose=2 "${SAVER_PATH}"
sig_info=$(codesign --display --verbose=2 "${SAVER_PATH}" 2>&1)
printf "%s\n" "${sig_info}"
if [[ "${sig_info}" != *"flags=0x10000(runtime)"* ]]; then
    echo "ERROR: hardened runtime is not enabled on the signed bundle." >&2
    exit 1
fi
if [[ "${sig_info}" != *"Developer ID Application"* ]]; then
    echo "ERROR: bundle is not signed with a 'Developer ID Application' certificate." >&2
    echo "       Notarization will be rejected. Check 'security find-identity -v -p codesigning'." >&2
    exit 1
fi

step "Zipping bundle for notarization"
rm -f "${NOTARY_ZIP}"
ditto -c -k --keepParent "${SAVER_PATH}" "${NOTARY_ZIP}"

step "Submitting to Apple notary service (this can take a few minutes)"
submit_output=$(xcrun notarytool submit "${NOTARY_ZIP}" \
    --keychain-profile "${NOTARY_PROFILE}" \
    --wait 2>&1) || true
printf "%s\n" "${submit_output}"

submission_id=$(printf "%s\n" "${submit_output}" | awk '/^[[:space:]]+id:/{print $2; exit}')

if [[ "${submit_output}" != *"status: Accepted"* ]]; then
    echo "" >&2
    echo "ERROR: Notarization did not succeed." >&2
    if [[ -n "${submission_id}" ]]; then
        echo "" >&2
        echo "Detailed log for submission ${submission_id}:" >&2
        xcrun notarytool log "${submission_id}" \
            --keychain-profile "${NOTARY_PROFILE}" >&2 || true
    fi
    exit 1
fi

step "Stapling notarization ticket"
xcrun stapler staple "${SAVER_PATH}"
xcrun stapler validate "${SAVER_PATH}"

step "Verifying Gatekeeper acceptance"
spctl --assess --type install --verbose=2 "${SAVER_PATH}" || true

step "Creating distribution zip"
rm -f "${RELEASE_ZIP}"
ditto -c -k --keepParent "${SAVER_PATH}" "${RELEASE_ZIP}"

printf "\n\033[1;32mDone.\033[0m Distribution archive: %s\n" "${RELEASE_ZIP}"
