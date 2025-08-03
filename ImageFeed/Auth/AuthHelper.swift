import Foundation

// MARK: - Protocol
protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Constants
    enum Constants {
        static let clientId = "client_id"
        static let redirectUri = "redirect_uri"
        static let responseType = "response_type"
        static let code = "code"
        static let scope = "scope"
        static let path = "/oauth/authorize/native"
    }
    
    // MARK: - Private Properties
    private let configuration: AuthConfiguration
    
    // MARK: - Initializers
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.clientId, value: configuration.accessKey),
            URLQueryItem(name: Constants.redirectUri, value: configuration.redirectURI),
            URLQueryItem(name: Constants.responseType, value: Constants.code),
            URLQueryItem(name: Constants.scope, value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == Constants.path,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == Constants.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
