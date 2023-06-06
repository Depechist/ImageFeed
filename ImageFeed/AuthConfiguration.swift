import Foundation

let accessKeyGlobal = "7NF2WMuQDuREuk7AGo8yMvVBeD9AyLpJjvqe7dCAO7g"
let secretKeyGlobal = "ilSmfh98pCbjqk8E30ZrygDH3BNQbCZd4nSZUTyyqI8"
let redirectURIGlobal = "urn:ietf:wg:oauth:2.0:oob"
let accessScopeGlobal = "public+read_user+write_likes"

let defaultBaseURLGlobal = URL(string: "https://api.unsplash.com")!
let authorizeURLStringGlobal = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authorizeURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authorizeURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authorizeURLString = authorizeURLString
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(
            accessKey: accessKeyGlobal,
            secretKey: secretKeyGlobal,
            redirectURI: redirectURIGlobal,
            accessScope: accessScopeGlobal,
            defaultBaseURL: defaultBaseURLGlobal,
            authorizeURLString: authorizeURLStringGlobal)
    }
}
