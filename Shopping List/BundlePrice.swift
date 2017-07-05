//
//  BundlePrice.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class BundlePrice: NSManagedObject {
    
    var valueDisplay: Int {
        set {
            value = Int32(newValue)
        }
        get {
            return Int(value)
        }
    }
    
    var bundleQuantityDisplay: Int {
        set {
            bundleQuantity = Int32(newValue)
        }
        get {
            return Int(bundleQuantity)
        }
    }

}
