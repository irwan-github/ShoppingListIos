//
//  ShoppingListItem.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListItem: NSManagedObject {
    
    var quantity: Int {
        get {
            return Int(quantityToBuy)
        }
        set {
            quantityToBuy = Int32(newValue)
        }
    }
    

}
