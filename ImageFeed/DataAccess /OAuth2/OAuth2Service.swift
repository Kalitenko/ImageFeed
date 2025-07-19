import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Shared Instance
    static let shared = OAuth2Service()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private let decoder = SnakeCaseJSONDecoder()
    private var lastTask: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        lastTask?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            Logger.error("Ошибка создания запроса")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let token):
                guard let self else { return }
                let accessToken = token.accessToken
                self.storage.token = accessToken
                Logger.success("Токен сохранён: \(token)")
                completion(.success(accessToken))
                self.lastTask = nil
                self.lastCode = nil
            case .failure(let error):
                Logger.error("Сетевая ошибка или ошибка с неподходящим статусом кода ответа: \(error)")
                completion(.failure(error))
            }
        }
        self.lastTask = task
        task.resume()
        
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            Logger.error("Ошибка в базовом URL Unsplash")
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
            Logger.error("Ошибка при создании URL для запроса токена")
            return nil
        }
        var request = URLRequest(url: url)
        request.setMethod(.post)
        return request
    }
}
