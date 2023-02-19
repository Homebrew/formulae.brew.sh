#!/usr/bin/env ruby
require "base64"
require "json"
require "openssl"
require "pathname"

ROOT = Pathname(__dir__).parent.freeze

# If we need to roll keys in the future, we'd likely expand this to take in multiple keys.
KEY_ID = ENV.fetch("JWS_SIGNING_KEY_ID").freeze
PRIVATE_KEY = OpenSSL::PKey::RSA.new(ENV.fetch("JWS_SIGNING_KEY")).freeze

[
  ROOT/"_site/api/formula.json",
  ROOT/"_site/api/cask.json",
].each do |path|
  data_string = path.read

  # The JSON structure throughout this script is a standard format. References:
  # - RFC7515 [JSON Web Signature (JWS)]
  # - RFC7797 [JWS Unencoded Payload Option]
  header = {
    # We're using RSA-PSS with SHA-512 - see RFC7518 (§3.5) or https://www.iana.org/assignments/jose/jose.xhtml.
    "alg": "PS512",
    # Standard JWS uses base64 URL-encoded payloads, but we don't need that and it compresses worse.
    # RFC7797 (§3) defines the `b64` option here we use.
    "b64": false,
    # Required by RFC7797 (§6): this tells clients they should not parse this if they don't understand what b64 means
    "crit": ["b64"],
  }
  header_base64 = Base64.urlsafe_encode64(header.to_json) # Base64URL is required - see RFC7515 (§3).

  # Formula defined by RFC7797 (§3).
  signing_input = "#{header_base64}.#{data_string}"
  signature_data = Base64.urlsafe_encode64(
    PRIVATE_KEY.sign_pss("SHA512", signing_input, salt_length: :digest, mgf1_hash: "SHA512")
  )

  # The rest of this file is defined by RFC7515 (§7.2.1).
  signature = {
    "protected": header_base64,
    "header": {
      "kid": KEY_ID, # Clients can identify which signature they are looking for by filtering by the key ID.
    },
    "signature": signature_data,
  }

  File.write(path.dirname/"#{path.sub_ext(".jws.json")}", {
    "payload": data_string,
    "signatures": [
      signature,
      # Multiple signatures could be supplied here
      # should we need to roll a new key at some point
      # and provide a transition path.
    ],
  }.to_json)
end
