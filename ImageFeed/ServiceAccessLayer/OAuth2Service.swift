import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    //TODO: Рекомендация по код-ревью 10 спринт: Раз это синглтон, то давай добавим приватный конструктор private init() {} (вернуться после изучения темы синглтонов)
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            guard let newValue = newValue else { return }
            OAuth2TokenStorage().token = newValue
        } }
    
    func fetchOAuthToken( // Получает 'code' на вход и используя его делает POST запрос с параметрами из API
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void) {
            assert(Thread.isMainThread)
            if lastCode == code { return }
            task?.cancel()
            lastCode = code
            
            let request = authTokenRequest(code: code)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume() //После код ревью 10 спринт убран дублирующий вызов task.resume при создании таски на 124 строке
        }
}

extension OAuth2Service {
    
    private func authTokenRequest(code: String) -> URLRequest { // Структура POST запроса согласно API
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        ) }
    
    private struct OAuthTokenResponseBody: Decodable { // Структура ответа POST запросу согласно API
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
    
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        return urlSession.objectTask(for: request, completion: { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let body):
                completion(.success(body))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}


