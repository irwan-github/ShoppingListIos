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
    var fetchedResultsController: NSFetchedResultsController<Item>? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = shoppingList?.name
        
        fetchItemsInShoppingList()
    }
    
    func fetchItemsInShoppingList() {
        
        guard let shoppingList = self.shoppingList else { return }
        
        //Request items in shopping list
        let requestForItems: NSFetchRequest<Item> = Item.fetchRequest()
        
        //Matching criteria
        let criteria = NSPredicate(format: "ANY shoppingLists = %@", shoppingList)
        requestForItems.predicate = criteria
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "name", ascending: true)]
        requestForItems.sortDescriptors = sortBy
        
        //Go fetch
        fetchedResultsController = NSFetchedResultsController(fetchRequest: requestForItems,
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shopping List Item", for: indexPath)
        
        // Configure the cell...
        let item = fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = item?.name
        cell.detailTextLabel?.text = item?.brand
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
