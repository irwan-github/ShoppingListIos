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
    
    //Fetched Property. Represent weak, one-way relationship
    @NSManaged public var selectedPrice: NSArray
    
    var quantityToBuyConvert: Int {
        get {
            return Int(quantityToBuy)
        }
        set {
            quantityToBuy = Int32(newValue)
        }
    }
    
    var priceTypeSelectedConvert: Int {
        get {
            return Int(priceTypeSelected)
        }
        set {
            priceTypeSelected = Int16(newValue)
        }
    }
    
    /**
     Currently used by Firebase module
    */
    var asDictionaryValues: [String: AnyObject] {
        get {
            var shoppingListItemDict = [String: AnyObject]()
            let brand = item?.brand ?? ""
            shoppingListItemDict["brand"] = brand as AnyObject
            shoppingListItemDict["name"] = (item?.name ?? "") as AnyObject
            shoppingListItemDict["quantity"] = quantityToBuyConvert as AnyObject
            let selectedPrice = self.selectedPrice[0] as! Price
            let valPrice = selectedPrice.valueConvert
            shoppingListItemDict["price"] = valPrice as AnyObject
            shoppingListItemDict["currencyCode"] = selectedPrice.currencyCode as AnyObject
            return shoppingListItemDict
        }
    }
}
