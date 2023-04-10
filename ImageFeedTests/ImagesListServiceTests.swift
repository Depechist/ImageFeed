//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Artem Adiev on 06.04.2023.
//
@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    
    func testFetchPhotos() {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for notification")
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }

    

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}
