import Foundation

enum Constants {
    static let accessKey = "vPWQIm7eo6hl7y-gQ1K_CcOpr6t1mmSFfP0NT44OScU" // client_id
    static let secretKey = "DR3UAvBXeSHqyiovqSPFeSWFzeWUMCyCKwpaz5wp5Q4" //client_secret
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
}

enum StorageKeys: String {
    case OAuthToken
}
