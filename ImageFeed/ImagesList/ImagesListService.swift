//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Artem Adiev on 05.04.2023.
//

import Foundation

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private (set) var photos: [Photo] = [] // Массив загруженных фотографий
    private var lastLoadedPage: Int? // Номер последней скачанной страницы
    private var task: URLSessionTask? // Таска для проверки идет ли закачка фото
    private let token = OAuth2TokenStorage().token // Токен для авторизации запроса
    
    func fetchPhotosNextPage() { // Функция для получения очередной страницы
        assert(Thread.isMainThread)
        task?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1 // Какую страницу загружать
        
        var request = URLRequest.makeHTTPRequest(path: "/photos/?page" + "\(lastLoadedPage!)" + "&&per_page=10", httpMethod: "get")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        
        if task != nil {
            let task = session.objectTask(for: request, completion: { [weak self] (result: Result<PhotoResult, Error>) in
                guard let self else { return }
                
                switch result {
                case .success(let photoResult):
                    DispatchQueue.main.async {
                        self.fetchPhoto([photoResult])
                    }
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                case .failure(_):
                    break
                }
            })
            
            self.task = task
            task.resume()
        }
        // TODO: Определяем идет ли сейчас загрузка фото: Добавить свойство task: URLSessionTask? (сохраняем в нём результат urlSession.objectTask), и если task != nil, то сетевой запрос в прогрессе.
    }
    
    func fetchPhoto(_ photoResult: [PhotoResult]) {
        for result in photoResult {
            let photo = [Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: result.createdAt,
                welcomeDescription: result.welcomeDescription,
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                isLiked: result.isLiked)]
        }
    }
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: String
        let welcomeDescription: String?
        let thumbImageURL: String?
        let largeImageURL: String?
        let isLiked: Bool
    }
    
    struct PhotoResult: Codable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String
        let welcomeDescription: String?
        let isLiked: Bool
        let urls: UrlsResult
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case width = "wight"
            case height = "height"
            case createdAt = "created_at"
            case welcomeDescription = "description"
            case isLiked = "liked_by_user"
            case urls = "urls"
        }
    }
    
    struct UrlsResult: Codable {
        let thumb: String
        let full: String
    }
}
