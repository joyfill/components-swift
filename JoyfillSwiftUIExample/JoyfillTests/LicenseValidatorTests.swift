import XCTest
@testable import Joyfill

final class LicenseValidatorTests: XCTestCase {

    // Provided valid RS256 JWT (should verify to true for collectionField)
    private let validLicense = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3N1ZXIiOiJKb3lmaWxsIExMQyIsImlzc3VlZCI6IlNlcnZpY2UgVHJhZGUiLCJjb2xsZWN0aW9uRmllbGQiOnRydWV9.EA_6ZEq9viV6omtSquXzHkGMMIOtqyR2utE6sq2swATFn7-GCR032WZyxkJhc7dSl9rBG0sSNdQhfLYafKpJ07LD2jK7izKXcl0lZ4OkYWUjBlJzZqQVS9VIfkJxZg_CshuyTI5Srzw0-V8AuuaC_Lu2oAEiRxwMqCWXuZl6uHloe2sO5XmMUcZnkoOlwmNwsKwgjmL2N_9-FuuMha15jcqsEcgoA4y2caGIGsXdJlvEaQKT81nn4fN79eYGHVv_EucFutZLLLDbtZLheIYaV9gIGUrFyX210AGZ56sp6tGuadHu9yqQGM_a6kK_d5A97tnMlOzg06-CvWXzEaibMduxX1fecg8_iu6mUgA_1HN8E5FjtBtDUa6qpcIVMlGFss2rWiu1NdDBnZPhu6ZDPy9-h3edVFrGF-qCAaEk_Kvg2H4qnRhdZOzvS1JA1ZgxTKTH9UeQff5QJ8k4h83rG5_aPHuAEwj1KD9nK_h9Qlk3ClIUO_vaRxYl-SyyOffCUBBbnwCdyV4oKE4giJAxBbsup_pKYGZFKgpeBx_s3hOFvrHjShd-pFqgBJJUGf8Niz2yge4y7U0efuG9XAYKeIqAm5KF9x7_oDMmXYswF554QOb49V8SCaOmjTs3hU2zf0TzWv4WTOLW78Ahd4q3-pJVG8535r1oOH8Z7YiI6-4"

    func testValidLicenseEnablesCollection() {
        let enabled = LicenseValidator.isCollectionEnabled(licenseToken: validLicense)
        XCTAssertTrue(enabled)
    }

    func testMissingLicenseDisablesCollection() {
        let enabled = LicenseValidator.isCollectionEnabled(licenseToken: nil)
        XCTAssertFalse(enabled)
    }

    func testTamperedLicenseDisablesCollection() {
        let tampered = validLicense + "tamper"
        let enabled = LicenseValidator.isCollectionEnabled(licenseToken: tampered)
        XCTAssertFalse(enabled)
    }
}


