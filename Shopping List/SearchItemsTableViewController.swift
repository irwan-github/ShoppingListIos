//
//  SearchItemsTableViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 14/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class SearchItemsTableViewController: FetchedResultsTableViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    var searchText: String? {
        didSet {
            searchItem()
        }
    }
    
    // MARK : - Properties
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // Mark: - Model
    var fetchedResultsController: NSFetchedResultsController<Item>?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = textField.text
        }
        
        return true
    }
    
    func searchItem() {
        
        //Request items
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
        print(">>>search \(searchText!)")
        //Matching
        let filter = NSPredicate(format: "name contains[cd] %@", searchText!)
        itemRequest.predicate = filter
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "name", ascending: true)]
        itemRequest.sortDescriptors = sortBy
        
        //Fetch
        fetchedResultsController = NSFetchedResultsController(fetchRequest: itemRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch  {
            print("Error search")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemTableViewCell
        
        // Configure the cell...
        let item = fetchedResultsController?.object(at: indexPath)
        
        itemCell.item = item
        
        return itemCell
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        
        let destinationVc = segue.destination
        
        if identifier == "show item detail" {
            
            let indexPathItemSelected = tableView.indexPathForSelectedRow
            
            _ = fetchedResultsController?.object(at: indexPathItemSelected!)
            
            _ = destinationVc as! ItemDetailViewController
            
            //itemViewController.item = item
        }
    }
    

}

extension SearchItemsTableViewController {
    
    // MARK: - Table view data source I
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
}
