//
//  ShoppingListsTableViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListsTableViewController: FetchedResultsTableViewController, UINavigationControllerDelegate {
    
    // MARK: API
    var persistContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    var selectedShoppingList: ShoppingList? {
        get {
            if let indexPathForSelectedShoppingList = tableView.indexPathForSelectedRow {
                return fetchedResultsController?.object(at: indexPathForSelectedShoppingList)
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Model
    fileprivate var fetchedResultsController: NSFetchedResultsController<ShoppingList>? = nil
    
    // MARK: - Properties
    @IBOutlet weak var addShoppingListButton: UIBarButtonItem!
    
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
        self.navigationController?.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        
        //Fetch all shopping list
        fetchShoppingLists()
        
        initializeShoppingList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //clearsSelectionOnViewWillAppear = (splitViewController?.isCollapsed)!
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
        
        let identifier = segue.identifier!
        
        var targetCtlr = segue.destination
        
        if let navCtlr = targetCtlr as? UINavigationController {
            
            targetCtlr = navCtlr.visibleViewController ?? targetCtlr
            
        }
        
        if identifier == "Show shopping list" {
            
            if let shoppingListCtlr = targetCtlr as? ShoppingListTableViewController {
                
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    
                    let aShoppingList = fetchedResultsController?.object(at: indexPath)
                    
                    shoppingListCtlr.shoppingList = aShoppingList
                    
                    //                    shoppingListCtlr.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    //                    shoppingListCtlr.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        } else if identifier == segueToEditMetadataId, let shoppingList = sender as? ShoppingList {
            
            if let shoopingListMetadataEditorVc = targetCtlr as? ShoppingListMetadataViewController  {
            
                shoopingListMetadataEditorVc.shoppingList = shoppingList
            }
        }
    }
    
    private let segueToEditMetadataId = "Edit shopping list metadata"
    
    lazy var onChangeShoppingListMetaDataHandler: (ShoppingList) -> Void = { shoppingList in
        self.performSegue(withIdentifier: self.segueToEditMetadataId, sender: shoppingList)
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "Shopping List", for: indexPath) as! ShoppingListSummaryTableViewCell
        
        // Configure the cell...
        cell.updateButton?.isHidden = !tableView.isEditing
        cell.updateButton?.isEnabled = tableView.isEditing
        let shoppingList = fetchedResultsController?.object(at: indexPath)
        
        cell.shoppingList = shoppingList
        
        return cell
    }
    

}

extension ShoppingListsTableViewController {
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        print("\(#function) - \(type(of: self))")
        let cell = tableView.cellForRow(at: indexPath) as? ShoppingListSummaryTableViewCell
        
        if tableView.isEditing {
            cell?.updateButton?.isHidden = false
            cell?.updateButton?.isEnabled = true
            cell?.onChangeShoppingListMetaDataHandler = onChangeShoppingListMetaDataHandler
        } else {
            cell?.updateButton?.isHidden = true
            cell?.updateButton?.isEnabled = false
            cell?.onChangeShoppingListMetaDataHandler = nil
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        print("\(#function) - \(type(of: self))")
        return .delete
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("\(#function) - \(type(of: self))")
        print("\(#function) - \(type(of: self)) - \(editingStyle.rawValue)")
        if editingStyle == .delete {
            // Delete the row from the data source
            
            guard let shoppingList = fetchedResultsController?.object(at: indexPath) else { return }
            
            persistContainer.viewContext.delete(shoppingList)
            
            try? persistContainer.viewContext.save()
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addShoppingListButton.isEnabled = !editing
    }
    
    /**
    Always show the landing view controller as the detail when master is this view controller
    */
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("\(#function) - \(type(of: self))")
        
        guard let detailViewController = splitViewController?.viewControllers[1] else { return }
        
        if viewController is ShoppingListsTableViewController, let title = detailViewController.title, title != "Landing view controller" {
            
            let landingViewController: UIViewController
            landingViewController = storyboard?.instantiateViewController(withIdentifier: "LandingViewController") ?? UIViewController()
            splitViewController?.showDetailViewController(landingViewController, sender: self)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("\(#function) - \(type(of: self))")
    }
}


