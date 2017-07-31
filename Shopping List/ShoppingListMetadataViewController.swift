//
//  ShoppingListMetadataViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 16/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

/// Creates, update and delete shopping list. Deleting a shopping list object here will delete cascade all its list items.
class ShoppingListMetadataViewController: UIViewController {
    
    // MARK: - Model
    var shoppingList: ShoppingList?
    
    @IBOutlet weak var shoppingListNameTextView: UITextField!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var shoppingListNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTopConstraint: NSLayoutConstraint!
    
    var persistentContainer: NSPersistentContainer? = AppDelegate.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //This view controller is presented as a popover in iPad while in iPhone it is modal. For popover, it is recommended to resize such that there is no big unaccounted space at the bottom. So the preferred size is to remove the bottom space. This adjustment is done for asthetic reason
        
        let minimumSuggestedHeight = (navigationController?.navigationBar.frame.height ?? 0 ) +
        shoppingListNameTopConstraint.constant +
        shoppingListNameTextView.frame.height +
        commentsTopConstraint.constant +
        commentsTextField.frame.height
        
        self.preferredContentSize = CGSize(width: 0, height: minimumSuggestedHeight)
        
        //Also in popover, the cancel button in the navigation bar is redundant and it is recommended not to show it.
        //Get the popover presenting controller
        guard let ppc = navigationController?.popoverPresentationController else { return }
        if ppc.arrowDirection != .unknown {
            navigationItem.leftBarButtonItem = nil
        }
        
    }
    
    func updateUi() {
        shoppingListNameTextView?.text = shoppingList?.name
        commentsTextField?.text = shoppingList?.comments
    }
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        
        if shoppingList == nil {
            let moc = (persistentContainer?.viewContext)!
            shoppingList = ShoppingList(context: moc)
        }
        
        shoppingList?.name = shoppingListNameTextView.text ?? ""
        shoppingList?.comments = commentsTextField.text ?? nil
        saveShoppingList()
    }
    
    func saveShoppingList() {
        
        let moc = (persistentContainer?.viewContext)!

        if moc.hasChanges {
            do {
                
                try moc.save()
                presentingViewController?.dismiss(animated: true, completion: nil)
            } catch {
                
                let nserror = error as NSError
                
                if let validationError = nserror.userInfo[AnyHashable("NSValidationErrorKey")] {
                    
                    displayErrorValuesFollowup(fieldName: validationError as! String)
                    
                }
            }
            
        }
    }
    
    func displayErrorValuesFollowup(fieldName: String) {
        
        let title = "You forgot to give the shopping list a " + fieldName
        
        let nameAlertVc = UIAlertController(title: title, message: "Provide the following", preferredStyle: .alert)
        nameAlertVc.addTextField(configurationHandler: { nameTextField in
            nameTextField.placeholder = "Name for the shopping list"
        })
        
        let doneAction = UIAlertAction(title: "Save", style: .default, handler: { alertAction in
            
            let name = nameAlertVc.textFields?.first?.text
            self.shoppingList?.name = name ?? ""
            self.saveShoppingList()
            
        })
        
        nameAlertVc.addAction(doneAction)
        nameAlertVc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {alertAction in
            
            self.persistentContainer?.viewContext.rollback()
            
        }))
        
        present(nameAlertVc, animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
