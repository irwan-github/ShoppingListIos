//
//  ShoppingListTableViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: FetchedResultsTableViewController {
    
    //API
    var shoppingList: ShoppingList?
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // Mark: - Model
    var fetchedResultsController: NSFetchedResultsController<ShoppingListItem>? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = shoppingList?.name
        
        fetchItemsInShoppingList()
        
        
    }
    
    func fetchItemsInShoppingList() {
        
        guard let shoppingList = self.shoppingList else { return }
        
        //Request items in shopping list
        let requestForShoppingListItem: NSFetchRequest<ShoppingListItem> = ShoppingListItem.fetchRequest()
        
        //Matching criteria
        let criteria = NSPredicate(format: "shoppingList = %@", shoppingList)
        requestForShoppingListItem.predicate = criteria
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "item.name", ascending: true)]
        requestForShoppingListItem.sortDescriptors = sortBy
        
        //Go fetch
        fetchedResultsController = NSFetchedResultsController(fetchRequest: requestForShoppingListItem,
                                                              managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch  {
            let nserror = error as NSError
            print("Error \(nserror) occured: \(nserror.userInfo)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shopping List Item", for: indexPath) as! ShoppingListItemTableViewCell
        
        // Configure the cell...
        let shoppingListItem = fetchedResultsController?.object(at: indexPath)
        
        cell.itemName.text = shoppingListItem?.item?.name
        cell.brand.text = shoppingListItem?.item?.brand
        cell.quantity.text = String(describing: (shoppingListItem?.quantity)!)
        return cell
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ShoppingListTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
}


















