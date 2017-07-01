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
        
        //var item: Item
        
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
        
//        do {
//            let result = try context.fetch(fetchRequest)
//            
//            if result.count == 1 {
//                return result[0]
//            } else if result.count == 0 {
//                return Item(context: context)
//            } else {
//                fatalError("Error: Item count should be 1 but is \(result.count)")
//            }
//            
//        } catch  {
//            let nserror = error as NSError
//            print("Error is \(nserror): \(nserror.userInfo)")
//        }
        
        //return item
        
    }
}
