//
//  Price.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class Price: NSManagedObject {
    
    var valueDisplay: Int {
        get {
            return Int(value)
        }
        set {
            value = Int32(newValue)
        }
    }
    
    var quantityDisplay: Int {
        set {
            quantity = Int32(newValue)
        }
        get {
            return Int(quantity)
        }
    }
    
    class func findPrices(of item: Item, moc: NSManagedObjectContext) throws -> [Price]? {
        
        //Create request
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        
        //Filter by
        let filter = NSPredicate(format: "item = %@", item)
        fetchRequest.predicate = filter
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "quantity", ascending: true)]
        fetchRequest.sortDescriptors = sortBy
        
        //Go fetch
        return try? moc.fetch(fetchRequest)
        
    }
}