//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Adiev on 02.06.2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL?) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    
    private struct APIConstants {
        static let authorizeURLString = "https://unsplash.com/oauth/authorize"
        static let code = "code"
        static let authorizationCodePath = "/oauth/authorize/native"
    }
    
    func viewDidLoad() {
        loadWebView()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func loadWebView() {
        var urlComponents = URLComponents(string: APIConstants.authorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: APIConstants.code),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        if let url = urlComponents.url {
            let request = URLRequest(url: url)
            
            didUpdateProgressValue(0)
            
            view?.load(request: request)
        }
    }
    
    func code(from url: URL?) -> String? {
        if
            let url = url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == APIConstants.authorizationCodePath,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == APIConstants.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
