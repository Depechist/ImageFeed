//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Artem Adiev on 07.06.2023.
//

import Foundation

class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
