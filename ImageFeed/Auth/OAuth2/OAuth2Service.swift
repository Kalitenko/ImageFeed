import Foundation

final class OAuth2Service {
    
    // MARK: - Shared Instance
    static let shared = OAuth2Service()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private let decoder = SnakeCaseJSONDecoder()
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ Ошибка создания запроса", #fileID, #function, #line)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self else { return }
                do {
                    let token = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = token.accessToken
                    self.storage.token = accessToken
                    print("✅ Токен сохранён: \(token)", #fileID, #function, #line)
                    completion(.success(accessToken))
                } catch let decodingError {
                    print("❌ Ошибка декодирования ответа: \(decodingError)", #fileID, #function, #line)
                    completion(.failure(decodingError))
                }
            case .failure(let error):
                print("❌ Сетевая ошибка или ошибка с неподходящим статусом кода ответа: \(error)", #fileID, #function, #line)
                completion(.failure(error))
            }
        }.resume()
        
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("❌ Ошибка в базовом URL Unsplash", #fileID, #function, #line)
            return nil
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("❌ Ошибка при создании URL для запроса токена", #fileID, #function, #line)
            return nil
        }
        var request = URLRequest(url: url)
        request.setMethod(.post)
        return request
    }
}
