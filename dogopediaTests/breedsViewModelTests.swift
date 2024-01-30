//
//  breedsViewModelTests.swift
//  dogopediaTests
//
//  Created by Matheus Queiroz on 29/01/2024.
//

import XCTest

@testable import dogopedia

final class breedsViewModelTests: XCTestCase {

    var viewModel: breedsViewModel?
    var requestMakerMock: mockRequestMaker?

    override func setUpWithError() throws {

        try super.setUpWithError()

        self.requestMakerMock = mockRequestMaker()
    }

    override func tearDownWithError() throws {

        self.requestMakerMock = nil
        self.viewModel = nil
    }

    func testModelRequestsPageZeroAtStart() {

        // Arrange
        guard let requestMakerMock else { return }

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequester: requestMakerMock)

        // Assert
        XCTAssertEqual(requestMakerMock.requestedPage, 0)
    }

    func testModelDoesNotRequestImagesWhenBreedsArrayIsEmpty() {

        // Arrange
        guard let requestMakerMock else { return }

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequester: requestMakerMock)

        // Assert
        XCTAssertFalse(requestMakerMock.didRequestImageInformation)
    }

    func testModelRequestsImagesWhenBreedsArrayIsNotEmpty() {

        // Arrange
        guard let requestMakerMock else { return }
        let testBreed = Breed(group: "TestGroup",
                              id: 0,
                              imageReference: "TestReference",
                              name: "TestBreed",
                              origin: "TestOrigin",
                              temperament: "TestTemper")
        requestMakerMock.breedsToReturn = [testBreed]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequester: requestMakerMock)

        // Assert
        XCTAssertTrue(requestMakerMock.didRequestImageInformation)
    }

    func testWhenScrollingDownTheNextPageIsRequested() {

        // Arrange
        guard let requestMakerMock else { return }
        let testBreed = Breed(group: "TestGroup",
                               id: 0,
                               imageReference: "TestReference",
                               name: "TestBreed",
                               origin: "TestOrigin",
                               temperament: "TestTemper")
        requestMakerMock.breedsToReturn = [testBreed]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequester: requestMakerMock)
        let firstPageRequested = requestMakerMock.requestedPage

        self.viewModel?.didScrollToBottom()
        let secondPageRequested = requestMakerMock.requestedPage

        // Assert
        guard let firstPageRequested = firstPageRequested,
              let secondPageRequested = secondPageRequested else {
            XCTFail("The requested numbers should exist")
            return
        }

        XCTAssertEqual(secondPageRequested, firstPageRequested + 1)
    }

    func testViewModelDoesNotStoreDuplicatedBreeds() {

        // Arrange
        guard let requestMakerMock else { return }
        let testBreed1 = Breed(group: "TestGroup",
                               id: 0,
                               imageReference: "TestReference",
                               name: "TestBreed",
                               origin: "TestOrigin",
                               temperament: "TestTemper")

        let testBreed2 = Breed(group: "TestGroup",
                               id: 1,
                               imageReference: "TestReference",
                               name: "TestBreed",
                               origin: "TestOrigin",
                               temperament: "TestTemper")

        requestMakerMock.breedsToReturn = [testBreed1, testBreed1, testBreed2, testBreed2]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequester: requestMakerMock)

        // Assert
        XCTAssertEqual(viewModel?.breeds.count, 2)
    }
}
