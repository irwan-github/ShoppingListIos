//
//  Helper.swift
//  Shopping List
//
//  Created by Mirza Irwan on 9/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

struct Helper {
    
    static func string(from number: Int, fractionDigits: Int) -> String? {
        
        let helper = CurrencyHelper()
        let formatter = NumberFormatter()
        formatter.locale = helper.userLocale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        let amount: Double = Double(number)/100
        return formatter.string(from: NSNumber(value: amount))
    }
}
