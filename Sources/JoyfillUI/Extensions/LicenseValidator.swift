import Foundation
import Security

/// Minimal JWT validator for Joyfill license enforcement.
/// - Verifies RS256 signature using embedded PEM public key
/// - Returns `collectionField` claim (default false)
struct LicenseValidator {
    static func isCollectionEnabled(licenseToken: String?) -> Bool {
        guard let token = licenseToken, !token.isEmpty else { return false }
        guard let payload = verifyAndDecodePayload(token: token) else { return false }
        if let value = payload["collectionField"] as? Bool {
            return value
        }
        return false
    }

    private static func verifyAndDecodePayload(token: String) -> [String: Any]? {
        let parts = token.split(separator: ".").map(String.init)
        guard parts.count == 3 else { return nil }
        let headerPart = parts[0]
        let payloadPart = parts[1]
        let signaturePart = parts[2]

        guard let signatureData = base64URLDecode(signaturePart) else { return nil }
        let signingInput = (headerPart + "." + payloadPart)
        guard let signingData = signingInput.data(using: .utf8) else { return nil }

        guard let publicKey = loadPublicKey(fromPEM: publicKeyPEM) else { return nil }

        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else { return nil }

        var error: Unmanaged<CFError>?
        let ok = SecKeyVerifySignature(publicKey, algorithm, signingData as CFData, signatureData as CFData, &error)
        guard ok && error == nil else { return nil }

        guard let payloadData = base64URLDecode(payloadPart) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: payloadData, options: []),
              let payload = json as? [String: Any] else {
            return nil
        }
        return payload
    }

    private static func loadPublicKey(fromPEM pem: String) -> SecKey? {
        var cleaned = pem
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")

        // Remove all whitespace/newlines to handle indented PEM blocks
        cleaned = cleaned.components(separatedBy: .whitespacesAndNewlines).joined()

        guard let derData = Data(base64Encoded: cleaned) else { return nil }

        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(derData as CFData, attributes as CFDictionary, &error) else {
            return nil
        }
        return secKey
    }

    private static func base64URLDecode(_ str: String) -> Data? {
        var base64 = str
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = 4 - (base64.count % 4)
        if padding < 4 { base64 += String(repeating: "=", count: padding) }
        return Data(base64Encoded: base64)
    }

    // Public key provided by Joyfill for license verification
    private static let publicKeyPEM = """
    -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAw69a7DUlaKia4iyPaZVo
            fOYwVZhLYL8MET83hFsH1rg7+RHgsGk2ifXyMyHfAuYVLPUKIOXCwewPC9QKUbOc
            9NepJqMoUeIG3b3okzO+XBUE5DZ5W8i0eug5ASYZDgLtNC1Fkpt8yYHHg0Yha4hv
            0Y7/G2r1cvNzuhsVRjzaLpwGzBww04lKipRIb5Iarvy+XcszDNZLXOFIavxTrK/R
            3rR8dTaDdZ3rJPyl6RNZnRwo1wxMBtOMRF5XmuszDyvaJKXvzywOXNmQNmsaCCLe
            VSS3uQ7WFeON5vylS5FMnRI8v3A15A+rhwp8GpOgNBnUokgLLI+DiQeC/leGeoYE
            XujH+9QUb6+7hp9RYcyqsFsNKC9/JQtEulj8OAZ9a37UiK9kxswJT9nIkml/fE8X
            Y/jVo7cVtCa9Y/g4dyPKlu6mkibYRNaNVJVA7cITduIyBCXDIrrIlBgdpD3emyS7
            nTNVaZeKqaylzGK64p89667t6GoghfrcQm/ntTRt1MettgTCykZ3Kz4xITsnoNKQ
            D/zQo/u44mUpfKE6bXQ/sf2DBIK2YliYg/JCv1QI/wDISethApFXVguAdbzSpB+S
            BH4z5XdbBtC5/rUYpYerduWonI2uc63HLpzdMj0v5OMyD4Rw5kaIhzmmvHzkkSLc
            hG0URbFR7wh9rH3avX8Q4A8CAwEAAQ==
            -----END PUBLIC KEY-----
    """
}


