//
//  CurrencyHelperTest.swift
//  Shopping List
//
//  Created by Mirza Irwan on 26/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import XCTest
@testable import Shopping_List

class CurrencyHelperTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let countryId = CurrencyHelper.getCountryIdentifier(from: "MYR")
        let res = CurrencyHelper.formatCurrency(for: "MYR", amount: 100)
        print(">>> \(countryId)")
        print(">>> \(res!)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
