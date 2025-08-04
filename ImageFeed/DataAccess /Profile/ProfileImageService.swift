import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    
    // MARK: - Shared Instance
    static let shared = ProfileImageService()
    
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Read-only Properties
    private(set) var avatarURL: String?
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private let decoder = SnakeCaseJSONDecoder()
    private var lastTask: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        guard let request = makeProfileImageRequestURL(username: username) else {
            Logger.error("Ошибка создания запроса")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                guard let self else { return }
                guard let profileImageURL = userResult.getSmallProfileImageURL()?.absoluteString else {
                    Logger.error("Не удалось получить URL аватарки")
                    completion(.failure(ProfileImageServiceError.invalidRequest))
                    return
                }
                self.avatarURL = profileImageURL
                Logger.success("URL аватарки получен: \(profileImageURL)")
                completion(.success(profileImageURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
                self.lastTask = nil
            case .failure(let error):
                Logger.error("Сетевая ошибка или ошибка с неподходящим статусом кода ответа: \(error)")
                completion(.failure(error))
            }
        }
        self.lastTask = task
        task.resume()
    }
    
    
    // MARK: - Private Methods
    private func makeProfileImageRequestURL(username: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            Logger.error("Ошибка в базовом URL API Unsplash")
            return nil
        }
        guard let url = URL(
            string: "/users/\(username)",
            relativeTo: baseURL
        ) else {
            Logger.error("Ошибка при создании URL для запроса аватарки профиля")
            return nil
        }
        guard let token = tokenStorage.token else {
            Logger.error("Нет авторизационного токена")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        Logger.info("\(request)\n")
        Logger.info("\(request.value(forHTTPHeaderField: "Authorization") ?? "❌ Нет токена в заголовке")")
        request.setMethod(.get)
        return request
    }
}

// MARK: - Logout
extension ProfileImageService {
    func logout() {
        avatarURL = nil
    }
}
