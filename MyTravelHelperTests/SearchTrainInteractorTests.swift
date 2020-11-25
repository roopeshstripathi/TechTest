//
//  SearchTrainInteractorTests.swift
//  MyTravelHelperTests
//
//  Created by roopesh.s.tripathi on 24/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainInteractorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_fetchallStations() throws {
        let sut = SearchTrainInteractor()
        sut.fetchAllStations()
    }

}
