import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    let accessToken = "token"
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: accessToken)
        }
        set {
            guard let newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: accessToken)
        }
    }
    
    func clearToken() {
        KeychainWrapper.standard.removeAllKeys()
    }
}
