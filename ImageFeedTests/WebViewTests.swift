//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Artem Adiev on 06.06.2023.
//
@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHepler: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThanOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHepler: authHelper)
        let progress: Float = 0.6

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHepler: authHelper)
        let progress: Float = 1
        
        // when
        let shoouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shoouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        // when
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        
        // then
        XCTAssertTrue(urlString.contains(configuration.authorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        // when
        let code = authHelper.code(from: url)
        
        // then
        XCTAssertEqual(code, "test code")
    }
    
    
    
}
