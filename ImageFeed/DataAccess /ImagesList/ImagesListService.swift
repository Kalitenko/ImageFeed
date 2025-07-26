import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
    case profileRequested
}

// MARK: - Constants
private enum ClassConstants {
    static let path = "/photos"
    static let authorizationHeader = "Authorization"
    static let header = "Bearer "
    static let pageParam = "page"
    static let perPageParam = "per_page"
    static let perPageParamValue = 10
    static let likePath = "/like"
}

final class ImagesListService {
    
    // MARK: - Shared Instance
    static let shared = ImagesListService()
    
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private let decoder = SnakeCaseJSONDecoder()
    private var isFetchingPhotos = false
    private var isChangingLike = false
    private let tokenStorage = OAuth2TokenStorage.shared
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard !isFetchingPhotos else { return }
        
        isFetchingPhotos = true
        defer { isFetchingPhotos = false }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            Logger.error("Ошибка создания запроса")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                guard let self else { return }
                let newPhotos = mapToPhotos(photoResults)
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                Logger.success("Фотографии получены: \(photos)")
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
            case .failure(let error):
                Logger.error("Сетевая ошибка или ошибка с неподходящим статусом кода ответа: \(error)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard !isChangingLike else { return }
        
        isChangingLike = true
        defer { isChangingLike = false }
        
        guard let request = makeLikeRequest(photoId: photoId, isLiked: isLike) else {
            Logger.error("Ошибка создания запроса")
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            Logger.error("Ошибка в базовом URL API Unsplash")
            return nil
        }
        guard var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(ClassConstants.path), resolvingAgainstBaseURL: true
        ) else {
            Logger.error("Ошибка при создании URL для запроса фотографий")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: ClassConstants.pageParam, value: page.description),
            URLQueryItem(name: ClassConstants.perPageParam, value: ClassConstants.perPageParamValue.description),
        ]
        guard let url = urlComponents.url else {
            Logger.error("Ошибка при создании полного URL для запроса фотографий")
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token = tokenStorage.token else {
            Logger.error("Нет авторизационного токена")
            return nil
        }
        request.setValue(ClassConstants.header + token, forHTTPHeaderField: ClassConstants.authorizationHeader)
        request.setMethod(.get)
        
        Logger.info("\(request)\n")
        Logger.info("\(request.value(forHTTPHeaderField: ClassConstants.authorizationHeader) ?? "❌ Нет токена в заголовке")")
        return request
    }
    
    private func makeLikeRequest(photoId id: String, isLiked: Bool) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            Logger.error("Ошибка в базовом URL API Unsplash")
            return nil
        }
        guard var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(ClassConstants.path), resolvingAgainstBaseURL: true
        ) else {
            Logger.error("Ошибка при создании URL для работы с фотографиями")
            return nil
        }
        
        urlComponents.path += "/\(id)\(ClassConstants.likePath)"
        
        guard let url = urlComponents.url else {
            Logger.error("Ошибка при создании полного URL для изменения лайков фотографий")
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token = tokenStorage.token else {
            Logger.error("Нет авторизационного токена")
            return nil
        }
        request.setValue(ClassConstants.header + token, forHTTPHeaderField: ClassConstants.authorizationHeader)
        let httpMethod = isLiked ? URLRequest.HTTPMethod.post : URLRequest.HTTPMethod.delete
        request.setMethod(httpMethod)
        
        Logger.info("\(request)\n")
        Logger.info("\(request.value(forHTTPHeaderField: ClassConstants.authorizationHeader) ?? "❌ Нет токена в заголовке")")
        return request
    }
    
    private func mapToPhotos(_ photosData: [PhotoResult]) -> [Photo] {
        return photosData.map { mapToPhoto($0) }
    }
    
    private func mapToPhoto(_ photoResult: PhotoResult) -> Photo {
        let photo = Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: photoResult.createdAt ?? Date(),
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
        return photo
    }
}

// MARK: - Logout
extension ImagesListService {
    func logout() {
        photos = []
        lastLoadedPage = Int.zero
    }
}
