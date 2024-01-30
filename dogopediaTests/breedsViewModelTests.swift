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
    var requestManagerMock: mockRequestManager?

    override func setUpWithError() throws {

        try super.setUpWithError()

        self.requestManagerMock = mockRequestManager()
    }

    override func tearDownWithError() throws {

        self.requestManagerMock = nil
        self.viewModel = nil
    }

    func testModelRequestsPageZeroAtStart() {

        // Arrange
        guard let requestManagerMock else { return }

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequestManager: requestManagerMock)

        // Assert
        XCTAssertEqual(requestManagerMock.requestedPage, 0)
    }

    func testModelDoesNotRequestImagesWhenBreedsArrayIsEmpty() {

        // Arrange
        guard let requestManagerMock else { return }

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequestManager: requestManagerMock)

        // Assert
        XCTAssertFalse(requestManagerMock.didRequestImageInformation)
    }

    func testModelRequestsImagesWhenBreedsArrayIsNotEmpty() {

        // Arrange
        guard let requestManagerMock else { return }
        let testBreed = Breed(group: "TestGroup",
                              id: 0,
                              imageReference: "TestReference",
                              name: "TestBreed",
                              origin: "TestOrigin",
                              temperament: "TestTemper")
        requestManagerMock.breedsToReturn = [testBreed]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequestManager: requestManagerMock)

        // Assert
        XCTAssertTrue(requestManagerMock.didRequestImageInformation)
    }

    func testWhenScrollingDownTheNextPageIsRequested() {

        // Arrange
        guard let requestManagerMock else { return }
        let testBreed = Breed(group: "TestGroup",
                               id: 0,
                               imageReference: "TestReference",
                               name: "TestBreed",
                               origin: "TestOrigin",
                               temperament: "TestTemper")
        requestManagerMock.breedsToReturn = [testBreed]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequestManager: requestManagerMock)
        let firstPageRequested = requestManagerMock.requestedPage

        self.viewModel?.didScrollToBottom()
        let secondPageRequested = requestManagerMock.requestedPage

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
        guard let requestManagerMock else { return }
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

        requestManagerMock.breedsToReturn = [testBreed1, testBreed1, testBreed2, testBreed2]

        // Act
        self.viewModel = breedsViewModel(controller: nil, networkRequestManager: requestManagerMock)

        // Assert
        XCTAssertEqual(viewModel?.breeds.count, 2)
    }
}
