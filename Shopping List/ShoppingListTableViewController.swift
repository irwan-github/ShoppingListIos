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
    
    // MARK : - API
    var shoppingList: ShoppingList? {
        didSet {
            updateUi()
        }
    }
    
    // MARK : - Properties
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // Mark: - Model
    var fetchedResultsController: NSFetchedResultsController<ShoppingListItem>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        navigationItem.title = shoppingList?.name
    }
    
    func updateUi() {
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
        
        // Configure the cell...ß
        let shoppingListItem = fetchedResultsController?.object(at: indexPath)
        
        cell.itemName.text = shoppingListItem?.item?.name
        cell.brand.text = shoppingListItem?.item?.brand
        let qtyToBuy = shoppingListItem?.quantity
        cell.quantityToBuy.setTitle(String(describing: qtyToBuy!), for: .normal)
        return cell
    }
    
     // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Do not create an item without a shopping list
        if shoppingList == nil {
            return false
        } else {
            return true
        }
    }
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        var destinationVc = segue.destination
            
        if let navigationController = destinationVc as? UINavigationController {
            
            destinationVc = navigationController.visibleViewController!
        }
        
        let shoppingEditorVc = destinationVc as! ShoppingListItemEditorViewController
        
        shoppingEditorVc.shoppingList = shoppingList
        
        if let id = segue.identifier, id == "Update Shopping List Item" {
            
            let cell = sender as! ShoppingListItemTableViewCell
            
            let indexPath = tableView.indexPath(for: cell)!
            
            let shoppingListItem = fetchedResultsController?.object(at: indexPath)
                
            shoppingEditorVc.shoppingLineItem = shoppingListItem
            
        }
     }
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



















