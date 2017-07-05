//
//  UnitPrice.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class UnitPrice: NSManagedObject {

    var valueDisplay: Int {
        get {
            return Int(value)
        }
        set {
            value = Int32(newValue)
        }
    }
    
    
}
