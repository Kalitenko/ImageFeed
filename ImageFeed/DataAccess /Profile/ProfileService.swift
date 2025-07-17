import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case profileRequested
}

final class ProfileService {
    
    // MARK: - Shared Instance
    static let shared = ProfileService()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private let decoder = SnakeCaseJSONDecoder()
    private var lastTask: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            assertionFailure("❗️")
            Logger.error("Ошибка создания запроса")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                guard let self else { return }
                let profile = mapToProfile(result: profileResult)
                self.profile = profile
                Logger.success("Информация профиля получена: \(profile)")
                completion(.success(profile))
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
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            Logger.error("Ошибка в базовом URL API Unsplash")
            return nil
        }
        guard let url = URL(
            string: "/me",
            relativeTo: baseURL
        ) else {
            Logger.error("Ошибка при создании URL для запроса профиля")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        Logger.info("\(request)\n")
        Logger.info("\(request.value(forHTTPHeaderField: "Authorization") ?? "❌ Нет токена в заголовке")")
        request.setMethod(.get)
        return request
    }
    
    private func mapToProfile(result: ProfileResult) -> Profile {
        let profile = Profile(
            username: result.username,
            name: "\(result.firstName ?? "") \(result.lastName ?? "")",
            loginName: "@\(result.username)",
            bio: result.bio ?? "",
        )
        return profile
    }
}
