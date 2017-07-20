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
    // Define a convenience initializer to get the language tag
    
    
    func isValid(currencyCode code: String) -> Bool {
        
        let filterCurrencyCode = NSPredicate(format: "SELF == %@", code)
        
        return availableCurrencyCodes.filtered(using: filterCurrencyCode).count > 0
    }
}
