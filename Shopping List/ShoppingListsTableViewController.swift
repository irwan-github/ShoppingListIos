//
//  ShoppingListsTableViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListsTableViewController: FetchedResultsTableViewController {
    
    // MARK: API
    var persistContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // MARK: - Model
    fileprivate var fetchedResultsController: NSFetchedResultsController<ShoppingList>? = nil
    
    // MARK: - Properties
    var indexPathOfDefaultShoppingList = IndexPath(row: 0, section: 0)
    
    fileprivate var defaultShoppingList: ShoppingList? {
        get {
            return fetchedResultsController?.object(at: indexPathOfDefaultShoppingList)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Fetch all shopping list
        fetchShoppingLists()
        
        initializeShoppingList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearsSelectionOnViewWillAppear = (splitViewController?.isCollapsed)!
    }
    
    // MARK: - Business
    private func initializeShoppingList() {
        
        let horizontalWidth = traitCollection.horizontalSizeClass
        
        if UIDevice.current.userInterfaceIdiom == .pad  || horizontalWidth == .regular {
            
            var shoppingListsVc = splitViewController?.viewControllers[1]
            
            if let shoppingListsNc = shoppingListsVc as? UINavigationController {
                shoppingListsVc = shoppingListsNc.visibleViewController
            }
            
            if let shoppingListsVc = shoppingListsVc as? ShoppingListTableViewController {
                shoppingListsVc.shoppingList = defaultShoppingList
                tableView.selectRow(at: indexPathOfDefaultShoppingList, animated: true, scrollPosition: .none)
            }
        }
    }
    
    private func fetchShoppingLists() {
        
        //Request for shopping list(s)
        let request: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        
        //Sort by
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        //Execute request
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: persistContainer.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            
            let nserror = error as NSError
            print("Fatal \(nserror):  \(nserror.userInfo)")
        }
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("\(#function) - \(type(of: self))")
        
        if segue.identifier != "showShoppingList" {
            return
        }
        
        var targetCtlr = segue.destination
        
        if let navCtlr = targetCtlr as? UINavigationController {
            
            targetCtlr = navCtlr.visibleViewController ?? targetCtlr
            
        }
        
        if let shoppingListCtlr = targetCtlr as? ShoppingListTableViewController {
            
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                
                let aShoppingList = fetchedResultsController?.object(at: indexPath)
                
                shoppingListCtlr.shoppingList = aShoppingList
                
                shoppingListCtlr.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                shoppingListCtlr.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
}

extension ShoppingListsTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shopping List", for: indexPath)
        
        // Configure the cell...
        let shoppingList = fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = shoppingList?.name
        cell.detailTextLabel?.text = shoppingList?.comments
        return cell
    }
}
