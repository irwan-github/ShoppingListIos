//
//  ShoppingListMetadataViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 16/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListMetadataViewController: UIViewController {
    
    // MARK: - Model
    var shoppingList: ShoppingList?
    
    @IBOutlet weak var shoppingListNameTextView: UITextField!
    @IBOutlet weak var commentsTextField: UITextField!
    
    var persistentContainer: NSPersistentContainer? = AppDelegate.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUi()
    }
    
    func updateUi() {
        shoppingListNameTextView?.text = shoppingList?.name
        commentsTextField?.text = shoppingList?.comments
    }
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        
        saveShoppingList()
    }
    
    func saveShoppingList() {
        
        let moc = (persistentContainer?.viewContext)!
        
        if shoppingList == nil {
            shoppingList = ShoppingList(context: moc)
        }

        shoppingList?.name = shoppingListNameTextView.text ?? ""
        shoppingList?.comments = commentsTextField.text ?? nil
        
        if moc.hasChanges {
            do {
                
                try moc.save()
                presentingViewController?.dismiss(animated: true, completion: nil)
            } catch {
                
                let nserror = error as NSError
                
                if let error = nserror.userInfo[AnyHashable("NSValidationErrorKey")] {
                    
                    displayErrorValuesFollowup(fieldName: error as! String)
                    
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
