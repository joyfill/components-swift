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
    MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAovJjOjuezMevI8lGj8ez
    puCFbWJENWH+jki1roZolNEy2PEZdElJr+9uMQKa+NLaT5qyE/gPThbSuSHssIXB
    dqjEotEsQBzpYEqa/T7suEX0dmdEdzzxWk6J4fUZptfACVUYbNcPln8xCKSOu8CC
    WuqL1FR/h7m45Etl7erYcN6HebaWlUF1z2Nitim8+PcE5sx/0Tab298/U0GZWmfv
    S/S4FXYGkST97rFWy+VxwCHyNblpHw+rQYegOINmBkTxAmy9UPGw37QKswEX3DWZ
    FTI5XDiiBQhSlLgsX3iqa4lapBt+UM6ryYP8nFqLrr2KrCud6SfGl1ixSQx/N55V
    SxRa/ZAfnJcOHjKQCVb+gzEZqkGkh5kDoR7a4f/qdBEm4Dvs7xSUJPEUZO2jvgHw
    g+FU1Cz6iTbs3uz9lsgqVYm9SeW6N3ZyY6GVF6j9uy+r0kkat8zTjPBesml0lmbH
    BUjpxUpnwBuX0HAlmOSNeXyWYao12+azf474Pm9p89dFlh8zGdNRcL3QBK0M7Ymk
    p75+nAPHdP0GofcSElpvarcg8sRoXAjh532N3Je/qE209s9BdSeFTaLeBW0K9knr
    ymOdRsNSdCbiObCha0CyOZYvv1hYm2X9gau8Wpill1ZkhGef9gbI+nRbw/bdHwEx
    T5tAsDz0zsS5rWFOoqzal+UCAwEAAQ==
    -----END PUBLIC KEY-----
    """
}


