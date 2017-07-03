//
//  ShoppingListEditorViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListItemEditorViewController: UIViewController {
    
    // MARK: - API
    var shoppingList: ShoppingList!
    
    var shoppingLineItem: ShoppingListItem?
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    fileprivate var validationState = ValidationState()
    
    fileprivate var changeState = ChangeState()
    
    @IBOutlet weak var itemNameTextField: UITextErrorField!
    
    @IBOutlet weak var brandTextField: UITextField!
    
    @IBOutlet weak var countryOriginTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBOutlet weak var quantityToBuyLabel: UILabel!
    
    @IBOutlet weak var quantityToBuyStepper: UIStepper!
    
    private var displayQty: Int {
        set {
            quantityToBuyLabel.text = String(newValue)
        }
        
        get {
            return Int(quantityToBuyStepper.value)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        itemNameTextField.delegate = self
        brandTextField.delegate = self
        countryOriginTextField.delegate = self
        descriptionTextField.delegate = self
        
        if shoppingLineItem == nil {
            validationState.handle(event: .onItemNew, handleNextStateUiAttributes: { nextState in
            
                self.deleteItemButton.isHidden = true
            })
        } else {
            validationState.handle(event: .onItemExist, handleNextStateUiAttributes: { nextState in
                
                self.itemNameTextField.text = self.shoppingLineItem?.item?.name
                self.brandTextField.text = self.shoppingLineItem?.item?.brand
                self.displayQty = (self.shoppingLineItem?.quantity)!
                self.quantityToBuyStepper.value = Double((self.shoppingLineItem?.quantity)!)
                self.countryOriginTextField.text = self.shoppingLineItem?.item?.countryOfOrigin
                self.descriptionTextField.text = self.shoppingLineItem?.item?.itemDescription
                self.itemNameTextField.isEnabled = false
                self.deleteItemButton.isHidden = false
            })
        }
    }
    
    @IBAction func onChangeQtyToBuy(_ sender: UIStepper) {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: { nextState in
            
            switch nextState {
                
            case .changed:
                self.doneButton.isEnabled = true
                self.displayQty = Int(sender.value)
                
            default:
                break
            }
        })
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        
        let onSaveEventhandler = ValidationState.OnSaveItemEventHandler(validate: { currentState in
            
            if let name = self.itemNameTextField.text, !name.isEmpty {
                
                switch currentState {
                    
                case .newItem:
                    do {
                        if try Item.isNameExist(self.itemNameTextField.text!, moc: self.persistentContainer.viewContext) {
                            self.itemNameTextField.errorText = "Name already exist"
                            return false
                        } else {
                            return true
                        }
                    } catch {
                        let nserror = error as NSError
                        print("Error \(nserror) : \(nserror.userInfo)")
                        return false
                    }
                    
                default:
                    return true
                }
                
            } else {
                self.itemNameTextField.errorText = "Name cannot be empty"
                return false
            }
            
        }, actionIfValidateTrue: {currentState in
            
            switch currentState {
                
            case .newItem:
                self.saveNew()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            case .existingItem:
                self.saveUpdate()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        })
        
        validationState.handle(event: .onSaveItem(onSaveEventhandler), handleNextStateUiAttributes: nil)
    }
    
    fileprivate func saveNew() {
        
        let moc = persistentContainer.viewContext
        
        do {
            let isExist = try Item.isNameExist(itemNameTextField.text!, moc: moc)
            
            if isExist {
                
                itemNameTextField.errorText = "Name already exist"
                return
            }
            
            let item = Item(context: moc)
            item.name = itemNameTextField.text!
            item.brand = brandTextField.text
            item.countryOfOrigin = countryOriginTextField.text
            item.itemDescription = descriptionTextField.text

            shoppingList.add(item: item, quantity: displayQty)
            
            try persistentContainer.viewContext.save()
            
        } catch  {
            let nserror = error as NSError
            print("Error \(nserror) : \(nserror.userInfo)")
        }
        
    }
    
    fileprivate func saveUpdate() {
        
        let item = shoppingLineItem?.item
        item?.countryOfOrigin = countryOriginTextField.text
        item?.brand = brandTextField.text
        item?.itemDescription = descriptionTextField.text
        shoppingLineItem?.quantity = displayQty
        
        do {
            if let hasChanges = shoppingLineItem?.managedObjectContext?.hasChanges, hasChanges {
                try shoppingLineItem?.managedObjectContext?.save()
            }
        } catch  {
            let nserror = error as NSError
            print("Error \(nserror) : \(nserror.userInfo)")
        }
    }
    
    @IBAction func onDeleteItem(_ sender: UIButton) {
    
        validationState.handle(event: .onDelete({ state in
            
            switch state {
                
            case .existingItem:
                self.deleteItemFromShoppingList()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        
        
        }), handleNextStateUiAttributes: nil)
    }
    
    
    private func deleteItemFromShoppingList() {
        
        let moc = persistentContainer.viewContext
        
        moc.delete(shoppingLineItem!)
        
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Error \(nserror) : \(nserror.userInfo)")
        }
        
        
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

extension ShoppingListItemEditorViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        changeState.transition(event: .onChangeCharacters) {
            
            [weak self] changeState in
            
            switch changeState {
                
            case .changed:
                self?.doneButton.isEnabled = true
                
            default:
                break
            }
            
        }
        
        validationState.handle(event: .onChangeCharacters) {
            
            validationState in
            self.itemNameTextField.errorText = nil
        }
        
        return true
    }
}
