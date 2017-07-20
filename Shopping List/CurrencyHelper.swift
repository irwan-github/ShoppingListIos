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
        
    init(languangeCode: String, countryCode: String) {
        let languageTag = languangeCode + "_" + countryCode
        userLocale = Locale(identifier: languageTag)
    }
    // Define a convenience initializer to get the language tag
}
