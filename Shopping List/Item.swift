//
//  Item.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class Item: NSManagedObject {
    
    class func findOrCreateNewItem(name: String, context: NSManagedObjectContext) throws -> Item {
        
        let item = try find(name: name, in: context)
        if let item = item {
            return item
        } else {
            return Item(context: context)
        }
    }
    
    class func find(name: String, in moc: NSManagedObjectContext) throws -> Item? {
        
        //Request item
        let fetchRequest: NSFetchRequest = Item.fetchRequest()
        
        //That matches the following criteria
        let criteria = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = criteria
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.sortDescriptors = sortBy
        
        //Fetch request
        var item: Item? = nil
        let result = try moc.fetch(fetchRequest)
        if result.count > 0 {
            item =  result[0]
        }
        
        return item
    }
    
    class func isNameExist(_ name: String, moc: NSManagedObjectContext) throws -> Bool {
        
        if let _ = try find(name: name, in: moc) {
            return true
        } else {
            return false
        }
    }
    
}
