import Foundation

extension URLRequest {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    mutating func setMethod(_ method: HTTPMethod) {
        self.httpMethod = method.rawValue
    }
}
