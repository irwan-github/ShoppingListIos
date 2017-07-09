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
    
    private var prices: [Price]? {
        didSet {
            unitPriceDisplay = unitPrice?.valueDisplay
            bundlePriceDisplay = bundlePrice?.valueDisplay
            bundleQtyDisplay = bundlePrice?.quantityDisplay ?? 2
        }
    }
    
    private var unitPrice: Price? {
        get {
            
            if let prices = prices, prices.count > 0 {
                let nsprices = prices as NSArray
                let unitPriceFilter = NSPredicate(format: "quantity == 1")
                let unitPriceRes = nsprices.filtered(using: unitPriceFilter)
                if unitPriceRes.count > 0 {
                    return unitPriceRes[0] as? Price
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    private var bundlePrice: Price? {
        get {
            
            if let prices = prices, prices.count > 0 {
                let nsprices = prices as NSArray
                let bundlePriceFilter = NSPredicate(format: "quantity >= 2")
                let bundlePriceRes = nsprices.filtered(using: bundlePriceFilter)
                if bundlePriceRes.count > 0 {
                    return bundlePriceRes[0] as? Price
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Properties
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
    
    @IBOutlet weak var priceTypeSc: UISegmentedControl!
    
    @IBOutlet weak var priceStackView: UIStackView!
    
    @IBOutlet weak var bundleQtyStackView: UIStackView!
    
    @IBOutlet weak var currencyCodeField: UITextField!
    
    @IBOutlet weak var unitPriceTextField: UITextField!
    
    @IBOutlet weak var bundlePriceTextField: UITextField!
    
    enum PriceType: Int {
        case unit_price = 0
        case bundle_price = 1
    }
    
    @IBOutlet weak var bundleQtyLabel: UILabel!
    
    @IBOutlet weak var bundleQtyStepper: UIStepper!
    
    private var quantityToBuyDisplay: Int {
        set {
            quantityToBuyLabel.text = String(newValue)
        }
        
        get {
            return Int(quantityToBuyStepper.value)
        }
    }
    
    private var bundleQtyDisplay: Int {
        set {
            bundleQtyLabel.text = String(describing: Int(newValue))
        }
        
        get {
            return Int(bundleQtyStepper.value)
        }
    }
    
    private var unitPriceDisplay: Int? {
        get {
            if let val = unitPriceTextField.text, !val.isEmpty {
                let dblVal = (Double(val))! * 100
                return Int(dblVal)
            } else {
                return nil
            }
        }
        set {
            
            if let newValue = newValue {
                unitPriceTextField.text = Helper.formatMoney(amount: newValue)
            } else {
                unitPriceTextField.text = nil
            }
        }
    }
    
    private var bundlePriceDisplay: Int? {
        
        get {
            
            if let val = bundlePriceTextField.text, !val.isEmpty {
                let dblVal = (Double(val))! * 100
                return Int(dblVal)
            } else {
                return nil
            }
        }
        
        set {
            
            if let newValue = newValue {
                bundlePriceTextField.text = Helper.formatMoney(amount: newValue)
            } else {
                bundlePriceTextField.text = nil
            }
        }
    }
    
    @IBOutlet weak var selectedPriceTypeSc: UISegmentedControl!
    
    private var selectedPrice: Int16 {
        get {
            return Int16(selectedPriceTypeSc.selectedSegmentIndex)
        }
        
        set {
            selectedPriceTypeSc.selectedSegmentIndex = Int(newValue)
        }
    }
    
    private let moneyTextFieldDelegate = MoneyUITextFieldDelegate()
    
    @IBAction func onDisplayPriceTypeInformation(_ sender: UISegmentedControl) {
        
        if let priceType = PriceType(rawValue: sender.selectedSegmentIndex) {
            
            switch priceType {
            case .unit_price:
                bundleQtyStackView.isHidden = true
                unitPriceTextField.placeholder = "Unit price"
                unitPriceTextField.isHidden = false
                bundlePriceTextField.isHidden = true
                
            case .bundle_price:
                bundleQtyStackView.isHidden = false
                bundlePriceTextField.placeholder = "Bundle Price"
                unitPriceTextField.isHidden = true
                bundlePriceTextField.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        doneButton.isEnabled = false
        itemNameTextField.delegate = self
        brandTextField.delegate = self
        countryOriginTextField.delegate = self
        descriptionTextField.delegate = self
        
        moneyTextFieldDelegate.vc = self
        moneyTextFieldDelegate.changeState = changeState
        unitPriceTextField.delegate = moneyTextFieldDelegate
        bundlePriceTextField.delegate = moneyTextFieldDelegate
        
        if shoppingLineItem == nil {
            validationState.handle(event: .onItemNew, handleNextStateUiAttributes: { nextState in
                
                switch nextState {
                case .newItem:
                    self.deleteItemButton.isHidden = true
                    self.selectedPrice = Int16(PriceType.unit_price.rawValue)
                    self.priceTypeSc.selectedSegmentIndex = Int(PriceType.unit_price.rawValue)
                    self.onDisplayPriceTypeInformation(self.priceTypeSc)
                    
                default:
                    break
                }
            })
        } else {
            validationState.handle(event: .onItemExist, handleNextStateUiAttributes: { nextState in
                
                switch nextState {
                    
                case .existingItem:
                    
                    self.itemNameTextField.text = self.shoppingLineItem?.item?.name
                    self.brandTextField.text = self.shoppingLineItem?.item?.brand
                    self.quantityToBuyDisplay = (self.shoppingLineItem?.quantity)!
                    self.quantityToBuyStepper.value = Double((self.shoppingLineItem?.quantity)!)
                    self.countryOriginTextField.text = self.shoppingLineItem?.item?.countryOfOrigin
                    self.descriptionTextField.text = self.shoppingLineItem?.item?.itemDescription
                    
                    //Although I can traverse item to get prices, it is difficult to work with NSSet.
                    //Therefore I do a fetch prices to get an array of prices
                    self.prices = try! Price.findPrices(of: (self.shoppingLineItem?.item)!, moc: self.persistentContainer.viewContext)
                    
                    if let selected = self.shoppingLineItem?.priceTypeSelected {
                        self.priceTypeSc.selectedSegmentIndex = Int(selected)
                    } else {
                        self.priceTypeSc.selectedSegmentIndex = Int(PriceType.unit_price.rawValue)
                    }
                    
                    self.onDisplayPriceTypeInformation(self.priceTypeSc)
                    self.itemNameTextField.isEnabled = false
                    self.deleteItemButton.isHidden = false
                    self.selectedPrice = (self.shoppingLineItem?.priceTypeSelected)!
                    
                default:
                    break
                }
            })
        }
    }
    
    @IBAction func onChangeQtyToBuy(_ sender: UIStepper) {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: { nextState in
            
            switch nextState {
                
            case .changed:
                self.doneButton.isEnabled = true
                self.quantityToBuyDisplay = Int(sender.value)
                
            default:
                break
            }
        })
    }
    
    @IBAction func onBundleQtyChange(_ sender: UIStepper) {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: { nextState in
            
            switch nextState {
                
            case .changed:
                self.doneButton.isEnabled = true
                self.bundleQtyDisplay = Int(sender.value)
                
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
            updateUnitPrice(of: item)
            updateBundlePrice(of: item)
            
            let shoppingLineItem = shoppingList.add(item: item, quantity: quantityToBuyDisplay)
            
            shoppingLineItem.priceTypeSelected = selectedPrice
            
            try persistentContainer.viewContext.save()
            
        } catch  {
            let nserror = error as NSError
            print(">>>>>\(nserror) : \(nserror.userInfo)")
        }
        
    }
    
    fileprivate func saveUpdate() {
        
        if let shoppingLineItem = shoppingLineItem, let item = shoppingLineItem.item {
            item.countryOfOrigin = countryOriginTextField.text
            item.brand = brandTextField.text
            item.itemDescription = descriptionTextField.text
            shoppingLineItem.quantity = quantityToBuyDisplay
            shoppingLineItem.priceTypeSelected = selectedPrice
            updateUnitPrice(of: item)
            updateBundlePrice(of: item)
        }
        
        do {
            if let hasChanges = shoppingLineItem?.managedObjectContext?.hasChanges, hasChanges {
                try shoppingLineItem?.managedObjectContext?.save()
            }
        } catch  {
            let nserror = error as NSError
            print(">>>>Error \(nserror) : \(nserror.userInfo)")
        }
    }
    
    private func updateUnitPrice(of item: Item) {
        
        if let unitPriceDisplay = unitPriceDisplay {
            
            if let unitPrice = unitPrice {
                unitPrice.currencyCode = "SGD"
                unitPrice.valueDisplay = unitPriceDisplay
                unitPrice.quantityDisplay = 1
            } else {
                
                let unitPrice = Price(context: persistentContainer.viewContext)
                unitPrice.currencyCode = "SGD"
                unitPrice.quantityDisplay = 1
                unitPrice.valueDisplay = unitPriceDisplay
                item.addToPrices(unitPrice)
            }
            
        } else if let unitPrice = unitPrice {
            persistentContainer.viewContext.delete(unitPrice)
        }
    }
    
    private func updateBundlePrice(of item: Item) {
        
        if let bundlePriceDisplay = bundlePriceDisplay {
            
            if let bundlePrice = bundlePrice {
                bundlePrice.currencyCode = "SGD"
                bundlePrice.valueDisplay = bundlePriceDisplay
                print("Bundle Qty display \(bundleQtyDisplay)")
                bundlePrice.quantityDisplay = bundleQtyDisplay
            } else {
                
                let bundlePrice = Price(context: persistentContainer.viewContext)
                bundlePrice.currencyCode = "SGD"
                print("Bundle Qty \(bundleQtyDisplay)")
                bundlePrice.quantityDisplay = bundleQtyDisplay
                bundlePrice.valueDisplay = bundlePriceDisplay
                print("Bundle Price \(bundlePriceDisplay)")
                item.addToPrices(bundlePrice)
            }
            
        } else if let bundlePrice = bundlePrice {
            persistentContainer.viewContext.delete(bundlePrice)
        }
    }
    
    @IBAction func onSelectPriceType(_ sender: UISegmentedControl) {
        changeState.transition(event: .onSelectPrice, handleNextStateUiAttributes: {
            changeState in
            
            switch changeState {
            case .changed:
                self.doneButton.isEnabled = true
                
            default:
                break
            }
        })
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
