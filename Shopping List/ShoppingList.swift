//
//  ShoppingList.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import CoreData

class ShoppingList: NSManagedObject {
    
    //Helper initialize
    
    static let entityName = "ShoppingList"
    
    convenience init(name: String, comments: String, insertInto context: NSManagedObjectContext) {
        
        //Returns the entity with the specified name from the managed object model associated with the specified managed object context’s persistent store coordinator.
        let shoppingListEntity = NSEntityDescription.entity(forEntityName: ShoppingList.entityName, in: context)
        
        if let shoppingListEntity = shoppingListEntity {
            self.init(entity: shoppingListEntity, insertInto: context)
            self.name = name
            self.comments = comments
            self.lastUpdatedOn = NSDate()
        } else {
            fatalError("Entity ShoppingList not found")
        }
    }
    
    class func findOrCreateNew(name: String, context: NSManagedObjectContext) -> ShoppingList? {
        
        var shoppingList: ShoppingList? = nil
        
        //Request Shopping List
        let shoppingListRequest: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        
        //Matching criteria
        let criteria = NSPredicate(format: "name = %@", name)
        shoppingListRequest.predicate = criteria
        
        //Fetch
        do {
            let shoppingLists = try context.fetch(shoppingListRequest)
            
            if shoppingLists.count == 1 {
                shoppingList = shoppingLists[0]
                //print(">>>Fetch \(shoppingList?.isInserted)")
            } else {
                shoppingList = ShoppingList(context: context)
                //print(">>>Instantiate \(shoppingList?.isInserted)")
            }
        } catch {
            let error = error as NSError
            fatalError("Error is \(error.userInfo)")
            
        }
        
        return shoppingList
        
    }
    
    func add(item: Item) -> ShoppingListItem{
        return add(item: item, quantity: 1)
    }
    
    func add(item: Item, quantity: Int) -> ShoppingListItem {
        
        let shoppingListItem = ShoppingListItem(context: item.managedObjectContext!)
        shoppingListItem.item = item
        shoppingListItem.quantity = quantity
        self.addToLineItems(shoppingListItem)
        return shoppingListItem
    }
}
