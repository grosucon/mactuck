#!/bin/zsh
# One-time: a self-signed code-signing identity so TCC grants survive rebuilds.
set -euo pipefail

NAME="MacTuck Dev"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-identity -v -p codesigning | grep -q "$NAME"; then
  echo "identity '$NAME' already exists"
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.conf" <<CONF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
CONF

openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
  -keyout "$TMP/key.pem" -out "$TMP/cert.pem" -config "$TMP/cert.conf" 2>/dev/null
openssl pkcs12 -export -out "$TMP/cert.p12" -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
  -passout pass:mactuck -name "$NAME" \
  -macalg sha1 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES

security import "$TMP/cert.p12" -k "$KEYCHAIN" -P mactuck -T /usr/bin/codesign -T /usr/bin/security
echo "macOS will ask for your login password to trust the certificate for code signing."
security add-trusted-cert -p codeSign -k "$KEYCHAIN" "$TMP/cert.pem"

security find-identity -v -p codesigning | grep "$NAME"
echo "done: run ./scripts/install.sh"
