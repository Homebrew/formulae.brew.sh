#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require "pathname"

ROOT = Pathname(__dir__).parent.freeze

# If we need to roll keys in the future, we'd likely expand this to take in multiple keys.
KEY_ID = ENV.fetch("JWS_SIGNING_KEY_ID").freeze
abort "Invalid JWS signing key ID" unless KEY_ID.match?(/\A[a-z0-9-]+\z/)

PUBLIC_KEY = begin
  key_data = (ROOT/"script/jws/#{KEY_ID}.pem").read
  abort "Pinned key for #{KEY_ID} contains a private key" if key_data.include?("PRIVATE KEY-----")

  OpenSSL::PKey::RSA.new(key_data)
rescue Errno::ENOENT
  abort "Missing pinned public key for #{KEY_ID}"
rescue SystemCallError, OpenSSL::PKey::PKeyError
  abort "Unable to load pinned public key for #{KEY_ID}"
end.freeze
abort "Pinned key for #{KEY_ID} contains a private key" if PUBLIC_KEY.private?

PRIVATE_KEY = OpenSSL::PKey::RSA.new(ENV.fetch("JWS_SIGNING_KEY")).freeze
unless PRIVATE_KEY.public_to_der == PUBLIC_KEY.public_to_der
  abort "Signing key does not match pinned public key for #{KEY_ID}"
end

[
  ROOT/"_site/api/formula.json",
  ROOT/"_site/api/cask.json",
  ROOT/"_site/api/formula_tap_migrations.json",
  ROOT/"_site/api/cask_tap_migrations.json",
  *(ROOT/"_site/api/internal").glob("*.json"),
].each do |path|
  data_string = path.read
  JSON.parse(data_string)

  # The JSON structure throughout this script is a standard format. References:
  # - RFC7515 [JSON Web Signature (JWS)]
  # - RFC7797 [JWS Unencoded Payload Option]
  header = {
    # We're using RSA-PSS with SHA-512 - see RFC7518 (§3.5) or https://www.iana.org/assignments/jose/jose.xhtml.
    "alg" => "PS512",
    # Standard JWS uses base64 URL-encoded payloads, but we don't need that and it compresses worse.
    # RFC7797 (§3) defines the `b64` option here we use.
    "b64" => false,
    # Required by RFC7797 (§6): this tells clients they should not parse this if they don't understand what b64 means
    "crit" => ["b64"],
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

  signed_path = path.sub_ext(".jws.json")
  signed_path.write({
    "payload": data_string,
    "signatures": [
      signature,
      # Multiple signatures could be supplied here
      # should we need to roll a new key at some point
      # and provide a transition path.
    ],
  }.to_json)

  # Verify the file that will be published, including its exact payload bytes.
  signed_data = JSON.parse(signed_path.read)
  signed_signature = signed_data.fetch("signatures").fetch(0)
  protected_header = signed_signature.fetch("protected")
  valid = signed_data.fetch("payload") == data_string &&
          signed_data.fetch("signatures").length == 1 &&
          signed_signature.fetch("header").fetch("kid") == KEY_ID &&
          JSON.parse(Base64.urlsafe_decode64(protected_header)) == header &&
          PUBLIC_KEY.verify_pss(
            "SHA512",
            Base64.urlsafe_decode64(signed_signature.fetch("signature")),
            "#{protected_header}.#{signed_data.fetch("payload")}",
            salt_length: :digest,
            mgf1_hash:   "SHA512",
          )
  abort "#{signed_path}: invalid API signature or payload" unless valid
end
