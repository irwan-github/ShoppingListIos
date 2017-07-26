//
//  CurrencyHelper.swift
//  Shopping List
//
//  Created by Mirza Irwan on 20/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

struct CurrencyHelper {
    
    var userLocale: Locale = Locale.current
    var availableCurrencyCodes = NSLocale.isoCurrencyCodes as NSArray
        
    init() {
        self.init(languangeCode: "en", countryCode: "SG")
    }
    
    init(languangeCode: String, countryCode: String) {
        let languageTag = languangeCode + "_" + countryCode
        userLocale = Locale(identifier: languageTag)
    }
    
    func getHomeCurrencyCode() -> String? {
        
        return userLocale.currencyCode
    }
    
    /**
     Validates a given currency code
    */
    func isValid(currencyCode code: String) -> Bool {
        let filterCurrencyCode = NSPredicate(format: "SELF == %@", code)
        return availableCurrencyCodes.filtered(using: filterCurrencyCode).count > 0
    }
    
    static func getCountryIdentifier(from currencyCode: String) -> String {
        let startIndex = currencyCode.startIndex
        let offsetIndex = currencyCode.index(startIndex, offsetBy: 2)
        return "en" + "_" + currencyCode.substring(to: offsetIndex)
    }
    
    static func getLocale(for currencyCode: String) -> Locale {
        let locale = Locale(identifier: getCountryIdentifier(from: currencyCode))
        return locale
    }
    
    static func getCurrencySymbol(from currencyCode: String) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = getLocale(for: currencyCode)
        formatter.internationalCurrencySymbol = currencyCode
        return formatter.currencySymbol
    }
    
    static func formatCurrency(for currencyCode: String, amount: Int) -> String? {
        let value: Double = Double(amount) / 100
        let valueAsNumber = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = CurrencyHelper.getLocale(for: currencyCode)
        formatter.internationalCurrencySymbol = currencyCode
        return formatter.string(from: valueAsNumber)
    }
}
