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
        
        //Request item
        let fetchRequest: NSFetchRequest = Item.fetchRequest()
        
        //Matching criteria
        let criteria = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = criteria
        
        //Fetch
        
        let result = try context.fetch(fetchRequest)
        
        if result.count == 1 {
            return result[0]
        } else if result.count == 0 {
            return Item(context: context)
        } else {
            fatalError("Error: Item count should be 1 but is \(result.count)")
        }
        
    }
    
    class func find(name: String, moc: NSManagedObjectContext) throws -> Item? {
        
        //Request item
        let fetchRequest: NSFetchRequest = Item.fetchRequest()
        
        //That matches the following criteria
        let criteria = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = criteria
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.sortDescriptors = sortBy
        
        //Fetch request
        return try moc.fetch(fetchRequest).first
        
    }
    
    class func isNameExist(_ name: String, moc: NSManagedObjectContext) throws -> Bool {
        
        if let _ = try find(name: name, moc: moc) {            
            return true
        } else {
            return false
        }
    }
}
