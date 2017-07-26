//
//  ExchangeRate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 26/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import XCTest
@testable import Shopping_List

class ExchangeRateTest: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let exchangeRate = ExchangeRate(foreignCurrencyCode: "MYR", costInForeignCurrencyToGetOneUnitOfBaseCurrency: 3)
        print(">>>Exchange rate is \(exchangeRate.convert(foreignAmount: 6) ?? "Fail")")
        ///exchangeRate
    }
    
    func testWebApiUrl() {
        let webApi = ExchangeRateWebApi(scheme: "http", host: "api.fixer.io", path: "/latest")
        guard let url =  webApi.getWebApiUrl(paramName: "base", baseCurrencyCode: "SGD") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(["http://api.fixer.io/latest?base=SGD"], [url.absoluteString])
    }
    
    func testWebApi() {
        let webApi = ExchangeRateWebApi(scheme: "http", host: "api.fixer.io", path: "/latest")
        webApi.getExchangeRates(paramName: "base", baseCurrencyCode: "SGD", targetCurrencyCode: "MYR")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
