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
        let task = session.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let imageURL):
                let profileImageURL = imageURL.profileImage.small
                print("PROFILE IMAGE URL:", profileImageURL)
                self.profileImageURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
            case .failure(let error):
                completion(.failure(error))
            }
        })
        self.task = task
        task.resume()
    }
    
    struct UserResult: Codable {
        let profileImage: ProfileImageURL
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImageURL: Codable {
        let small: String
        let medium: String
        let large: String
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
