import Foundation

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private let token = OAuth2TokenStorage().token
    private (set) var profileImageURL: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfileImageURL(username: String?, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(username: username!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(UserResult.self, from: data)
                        let profileImageURL = ProfileImage(decodedData: decodedData)
                        print("PROFILE IMAGE URL:", self.profileImageURL!)
                        self.profileImageURL = profileImageURL.profileImage["small"]
                        completion(.success(self.profileImageURL!))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": self.profileImageURL!])
                    } catch let error {
                        completion(.failure(error))
                    }
                } else {
                    return
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    
    
    struct UserResult: Codable {
        let profileImage: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImage: Codable {
        let profileImage: [String: String]
        
        init(decodedData: UserResult) {
            self.profileImage = decodedData.profileImage
        }
    }
}

extension ProfileImageService {
    private func makeRequest(username: String) -> URLRequest {
        guard let url = URL(string: "\(defaultBaseURL)" + "/users" + "/:" + "\(username)") else {
            fatalError("Failed to create URL for profileImage") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
