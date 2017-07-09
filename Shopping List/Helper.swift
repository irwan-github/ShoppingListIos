//
//  Helper.swift
//  Shopping List
//
//  Created by Mirza Irwan on 9/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

struct Helper {
    
    static func formatMoney(amount: Int) -> String {
        let dollars = amount / 100
        let cents = amount % 100
        let centsString = String(cents)
        return String(dollars) + "." + (centsString.characters.count == 1 ? "0" + centsString : centsString)
    }
}
