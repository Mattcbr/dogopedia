//
//  searchViewModelTest.swift
//  dogopediaTests
//
//  Created by Matheus Queiroz on 29/01/2024.
//

import XCTest

@testable import dogopedia

final class searchViewModelTest: XCTestCase {

    var viewModel: searchViewModel?
    var requestMakerMock: mockRequestMaker?

    override func setUpWithError() throws {

        try super.setUpWithError()

        self.requestMakerMock = mockRequestMaker()
    }

    override func tearDownWithError() throws {

        self.requestMakerMock = nil
        self.viewModel = nil
    }

    func testWhenBreedsNotFoundSearchReturnsError() {

        // Arrange
        guard let requestMakerMock else { return }
        self.viewModel = searchViewModel(controller: nil, networkRequester: requestMakerMock)
        let expectation = XCTestExpectation(description: "Test search not found expectation")
        var state: viewState?

        // Act
        viewModel?.performSearch(withTerm: "test") { resultState in
            state = resultState
            expectation.fulfill()
        }

        // Assert
        self.wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(state, .error)
    }

    func testWhenBreedsFoundSearchReturnsSuccess() {

        // Arrange
        guard let requestMakerMock else { return }

        let testBreed = Breed(group: "TestGroup", 
                              id: 0,
                              imageReference: "TestReference",
                              name: "TestBreed",
                              origin: "TestOrigin",
                              temperament: "TestTemper")

        requestMakerMock.breedsToReturn = [testBreed]
        self.viewModel = searchViewModel(controller: nil, networkRequester: requestMakerMock)
        let expectation = XCTestExpectation(description: "Test search not found expectation")
        var state: viewState?

        // Act
        viewModel?.performSearch(withTerm: "test") { resultState in
            state = resultState
            expectation.fulfill()
        }

        // Assert
        self.wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(state, .successful)
    }

    func testWhenBreedsFoundSearchRequestsImages() {

        // Arrange
        guard let requestMakerMock else { return }

        let testBreed = Breed(group: "TestGroup",
                              id: 0,
                              imageReference: "TestReference",
                              name: "TestBreed",
                              origin: "TestOrigin",
                              temperament: "TestTemper")

        requestMakerMock.breedsToReturn = [testBreed]
        self.viewModel = searchViewModel(controller: nil, networkRequester: requestMakerMock)
        let expectation = XCTestExpectation(description: "Test search not found expectation")

        // Act
        viewModel?.performSearch(withTerm: "test") { _ in
            expectation.fulfill()
        }

        // Assert
        self.wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(requestMakerMock.didRequestImageInformation)
    }
}
