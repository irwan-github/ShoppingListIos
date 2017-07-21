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
    
    // MARK: - API and Model
    
    var shoppingList: ShoppingList!
    
    var shoppingListItem: ShoppingListItem? {
        didSet {
            item = shoppingListItem?.item
        }
    }
    
    let userLocale: Locale = CurrencyHelper(languangeCode: "en", countryCode: "SG").userLocale
    
    private var item: Item? {
        didSet {
            
            //New objects inserted into a managed object context are assigned a temporary ID which is replaced with a permanent one once the object gets saved to a persistent store. Assigning of new item to this property must NOT update UI fields
            
            let isNewItem = (item?.objectID.isTemporaryID) ??  true
            
            if !isNewItem {
                populateItemFields(item: item)
            }
            
        }
    }
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // MARK: - State Transition variables
    
    fileprivate var changeState = ChangeState()
    
    fileprivate var pictureState = PictureState()
    
    fileprivate var selectedPriceState = SelectedPriceState()
    
    fileprivate var validationListItemState = ValidationListItemState()
    
    fileprivate var validationItemState = ValidationItemState()
    
    // MARK: - Properties
    
    /**
     An item have more than one price. A property observer will create a unit price and bundle price and set the price fields.
     */
    private var prices: NSSet? {
        didSet {
            
            guard let prices = prices else { return }
            
            unitPrice = Price.filterSet(of: prices, match: .unit)
            unitPriceVc = unitPrice?.valueConvert
            
            bundlePrice = Price.filterSet(of: prices, match: .bundle)
            bundlePriceVc = bundlePrice?.valueConvert
            
            if let bundlePrice = bundlePrice {
                bundleQtyStepper?.value = Double(bundlePrice.quantityConvert)
                bundleQtyPricingInfoVc = bundlePrice.quantityConvert
                
            } else {
                bundleQtyStepper?.value = Double(2)
                bundleQtyPricingInfoVc = 2
            }
        }
    }
    
    private var unitPrice: Price?
    
    private var bundlePrice: Price?
    
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var brandTextField: UITextField!
    
    @IBOutlet weak var countryOriginTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteItemButton: UIBarButtonItem!
    
    /**
     Shared by bundle pricing and unit pricing. Event handler for shopping list item will set the proper quantity value and selected price type. Do not set anywhere else.
     */
    @IBOutlet weak var quantityToBuyLabel: UILabel!
    
    /**
     Shared by bundle pricing and unit pricing. Event handler for shopping list item will set the proper quantity value and selected price type. Do not set anywhere else.
     */
    @IBOutlet weak var quantityToBuyStepper: UIStepper!
    
    @IBOutlet weak var pricingInformationSc: UISegmentedControl!
    
    @IBOutlet weak var priceStackView: UIStackView!
    
    @IBOutlet weak var bundleQtyStackView: UIStackView!
    
    @IBOutlet weak var unitCurrencyCodeField: UITextField! {
        didSet {
            unitCurrencyCodeField.delegate = currencyCodeTextFieldDelegate
        }
    }
    
    @IBOutlet weak var unitPriceTextField: UITextField!
    
    @IBOutlet weak var bundleCurrencyCodeTextField: UITextField! {
        didSet {
            bundleCurrencyCodeTextField.delegate = currencyCodeTextFieldDelegate
        }
    }
    
    @IBOutlet weak var bundlePriceTextField: UITextField!
    
    @IBOutlet weak var bundleQtyLabel: UILabel!
    
    @IBOutlet weak var bundleQtyStepper: UIStepper!
    
    /**
     Shared by bundle pricing and unit pricing. The value of this property depends on the state of the price selected.
     Set quantityToBuyStepper from Int to Double and vice-versa
     */
    private var quantityToBuyStepperConvert: Int {
        set {
            quantityToBuyStepper.value = Double(newValue)
        }
        
        get {
            let p = quantityToBuyStepper.value
            let q = Int(p)
            return q
        }
    }
    
    /**
     Pricing information for bundle.
     Converts Double to Int for getter.
     Set value of bundleQtyLabel.text after converting Double to String.
     */
    private var bundleQtyPricingInfoVc: Int? {
        set {
            let setValue = newValue ?? 2
            bundleQtyLabel?.text = String(describing: setValue)
        }
        
        get {
            return Int(bundleQtyStepper?.value ?? 2)
        }
    }
    
    /**
     Pricing information for unit
     */
    private var unitPriceVc: Int? {
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
                unitPriceTextField?.text = Helper.formatMoney(amount: newValue)
                unitCurrencyCodeField?.text = unitPrice?.currencyCode ?? userLocale.currencyCode
                
            } else {
                unitPriceTextField?.text = nil
                unitCurrencyCodeField?.text = userLocale.currencyCode
            }
        }
    }
    
    /**
     Pricing information for bundle
     */
    private var bundlePriceVc: Int? {
        
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
                bundlePriceTextField?.text = Helper.formatMoney(amount: newValue)
                bundleCurrencyCodeTextField?.text = bundlePrice?.currencyCode ?? userLocale.currencyCode
            } else {
                bundlePriceTextField?.text = nil
                bundleCurrencyCodeTextField?.text = userLocale.currencyCode
            }
        }
    }
    
    /**
     ViewController's image model
     */
    fileprivate var itemImageVc: ItemPicture?
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    // MARK: Delegates
    private let moneyTextFieldDelegate = MoneyUITextFieldDelegate()
    
    private lazy var currencyCodeTextFieldDelegate = CurrencyCodeTextFieldDelegate()
    
    private lazy var displayAlertAction: ((UIAlertController) -> Void) = {
        
        alertController in
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        
        currencyCodeTextFieldDelegate.displayAlertAction = displayAlertAction
        
        currencyCodeTextFieldDelegate.changeState = changeState
        
        currencyCodeTextFieldDelegate.changeStateUiAttributesHandler = changeStateAttributeHandler
        
        priceSwitchController = PriceUiSelectorController(unitPriceUi: (unitPriceSwitch, unitPriceLabel),
                                                          bundlePriceUi: (bundlePriceSwitch, bundlePriceLabel))
        
        doneButton.isEnabled = false
        itemNameTextField.delegate = self
        brandTextField.delegate = self
        countryOriginTextField.delegate = self
        descriptionTextField.delegate = self
        
        moneyTextFieldDelegate.vc = self
        moneyTextFieldDelegate.changeState = changeState
        unitPriceTextField.delegate = moneyTextFieldDelegate
        bundlePriceTextField.delegate = moneyTextFieldDelegate
        
        if shoppingListItem == nil {
            validationListItemState.handle(event: .onListItemNew, handleNextStateUiAttributes: validationStateUiPropertiesHandler)
        } else {
            validationListItemState.handle(event: .onListItemExist, handleNextStateUiAttributes: validationStateUiPropertiesHandler)
            validationItemState.handle(event: .onExistingItem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Adapt from model to popover
        
        //Get the popover presentation controller from navigation controller. It is not the same as this editor's popover presentation controller and it will not work. Also the cancel button is in navigation item which is contained in the navigation controller navigation bar
        if let myPopoverPresentationController = navigationController?.popoverPresentationController {
            if myPopoverPresentationController.arrowDirection != .unknown {
                print("popover. not model")
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        changeState.transition(event: .onCancel(changeStateOnCancelEventAction), handleNextStateUiAttributes: changeStateAttributeHandler)
    }
    
    // MARK: - State: Selected price type, Pricing information, Quantity to buy logic
    
    private var priceSwitchController: PriceUiSelectorController?
    
    @IBAction func onSwitchUnitPrice(_ sender: UISwitch) {
        priceSwitchController?.selectPriceType(priceType: sender.isOn ? .unit : .bundle)
        onSelectPriceType(priceType: sender.isOn ? .unit : .bundle)
    }
    
    @IBAction func onSwitchBundlePrice(_ sender: UISwitch) {
        priceSwitchController?.selectPriceType(priceType: sender.isOn ? .bundle : .unit)
        onSelectPriceType(priceType: sender.isOn ? .bundle : .unit)
    }
    
    /**
     I need a stored property for quantity to buy at UNIT pricing because the quantity to buy stepper is used for both unit and quantity price.
     A property observer set the quantityToBuyLabel
     */
    private var quantityToBuyAtUnit: Int = 0 {
        didSet {
            quantityToBuyLabel.text = String(quantityToBuyAtUnit)
        }
    }
    
    /**
     I need a stored property for quantity to buy at BUNDLE pricing because the quantity to buy stepper is used for both unit and quantity price.
     A property observer set the quantityToBuyLabel
     */
    private var quantityToBuyAtBundle: Int = 0 {
        didSet {
            quantityToBuyLabel.text = String(quantityToBuyAtBundle)
        }
    }
    
    /**
     Event handler for shopping list item will set the proper quantity value and selected price type. Do not set anywhere else.
     */
    @IBOutlet weak var unitPriceSwitch: UISwitch!
    
    /**
     Event handler for shopping list item will set the proper quantity value and selected price type. Do not set anywhere else.
     */
    @IBOutlet weak var bundlePriceSwitch: UISwitch!
    
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var bundlePriceLabel: UILabel!
    
    /**
     Event causes the display of relevent pricing information and hiding of irrelevant pricing information depending on the price type.
     */
    @IBAction func onDisplayPriceTypeInformation(_ sender: UISegmentedControl) {
        
        if let priceType = PriceType(rawValue: sender.selectedSegmentIndex) {
            
            setPricingControlAttributes(priceType: priceType)
        }
    }
    
    @IBOutlet weak var unitPriceStackView: UIStackView!
    
    @IBOutlet weak var bundlePriceStackView: UIStackView!
    
    /**
     Display and hide price control depending on the price type
     */
    func setPricingControlAttributes(priceType: PriceType) {
        
        switch priceType {
        case .unit:
            bundlePriceStackView.isHidden = true
            unitPriceStackView.isHidden = false
            bundleQtyStackView.isHidden = true
            unitPriceTextField.isHidden = false
            bundlePriceTextField.isHidden = true
            unitCurrencyCodeField.isHidden = false
            bundleCurrencyCodeTextField.isHidden = true
            
        case .bundle:
            bundlePriceStackView.isHidden = false
            unitPriceStackView.isHidden = true
            bundleQtyStackView.isHidden = false
            unitPriceTextField.isHidden = true
            bundlePriceTextField.isHidden = false
            unitCurrencyCodeField.isHidden = true
            bundleCurrencyCodeTextField.isHidden = false
        }
    }
    
    /**
     The requirement is to sync the quantity to buy value with pricing info's bundle quantity when the selected price is bundle quantity.
     If the selected price is unit price, the quantity to buy value is NOT changed.
     */
    @IBAction func onBundleQtyChange(_ sender: UIStepper) {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
        selectedPriceState.transition(event: .onBundleQtyChange(Int(sender.value), onBundleQtyChangeEventHandler), handleStateUiAttribute: nil)
    }
    
    /**
     The requirement is to sync the quantity to buy value with pricing info's bundle quantity when the selected price is bundle quantity.
     If the selected price is unit price, the quantity to buy value is NOT changed.
     The pricing info's bundle quantity will change at all times.
     */
    lazy var onBundleQtyChangeEventHandler: (SelectedPriceState, Int) -> Void = { selectedPriceState, newBundleQty in
        
        switch selectedPriceState {
        case .bundlePrice:
            self.quantityToBuyAtBundle = newBundleQty
            self.quantityToBuyStepperConvert = newBundleQty
            
            self.bundleQtyPricingInfoVc = newBundleQty
            
            //Set the stepper config for bundle pricing
            self.quantityToBuyStepper.minimumValue = Double(newBundleQty)
            self.quantityToBuyStepper.stepValue = Double(newBundleQty)
            
        case .unitPrice:
            
            //The pricing info's bundle quantity will change at all times.
            self.bundleQtyPricingInfoVc = newBundleQty
        }
    }
    
    func onSelectPriceType(priceType: PriceType) {
        changeState.transition(event: .onSelectPrice, handleNextStateUiAttributes: {
            changeState in
            
            switch changeState {
            case .changed:
                self.doneButton.isEnabled = true
                
            default:
                break
            }
        })
        
        selectedPriceState.transition(event: .onSelectPriceType(priceType, onSelectPriceTypeEventHandler), handleStateUiAttribute: pricingControlsAttributeHandler)
    }
    
    
    
    
    /**
     The handler of the event of selecting the price type configures the behavior of the stepper to respond differently depending on selected price type. Because there is only one stepper for quantity to buy, for either unit or bundle price, I need to do book-keeping in order for the proper quantities to buy to be valid and not lost. Upon changing bundle price, use the stored property quantityToBuyAtBundle to update the quantity to buy label.
     */
    lazy var onSelectPriceTypeEventHandler: (PriceType) -> Void = { priceType in
        
        switch priceType {
        case .bundle:
            
            //Use the stored property quantityToBuyAtBundle to update the quantity to buy label
            if self.quantityToBuyAtBundle == 0 {
                self.quantityToBuyAtBundle = self.bundleQtyPricingInfoVc ?? 2
                
            } else {
                //Artificially set the value to notify property observer
                self.quantityToBuyAtBundle = self.quantityToBuyAtBundle + 0
            }
            
            //Set the stepper config for bundle pricing
            self.quantityToBuyStepper.minimumValue = Double(self.bundleQtyPricingInfoVc ?? 2)
            self.quantityToBuyStepper.stepValue = self.quantityToBuyStepper.minimumValue
            
            //Set the stepper to the correct value for bundle price
            self.quantityToBuyStepperConvert = self.quantityToBuyAtBundle
            
        case .unit:
            
            //Update the quantity to buy to unit quantity
            if self.quantityToBuyAtUnit == 0 {
                self.quantityToBuyAtUnit = 1
            } else {
                //Artificially set the value to notify property observer
                self.quantityToBuyAtUnit = self.quantityToBuyAtUnit + 0
            }
            
            //Set the stepper config for bundle pricing
            self.quantityToBuyStepper.minimumValue = 1
            self.quantityToBuyStepper.stepValue = self.quantityToBuyStepper.minimumValue
            
            //Set the stepper to the correct value for unit price
            self.quantityToBuyStepperConvert = self.quantityToBuyAtUnit
        }
        
    }
    
    /**
     The handler uses quantityToBuyStepper control to set the quantity to buy display. Prior to this event, the event of selecting the price type configures the behavior of the stepper to respond differently depending on selected price type.
     */
    lazy var onChangeQtyToBuyEventHandler: (SelectedPriceState) -> Void = { selectedPriceState in
        
        switch selectedPriceState {
        case .bundlePrice:
            
            //Update the quantity to buy to bundle quantity
            self.quantityToBuyAtBundle = self.quantityToBuyStepperConvert
            
        case .unitPrice:
            
            //Update the quantity to buy to bundle quantity
            self.quantityToBuyAtUnit = self.quantityToBuyStepperConvert
        }
        
    }
    
    /**
     Control the state of controls for pricing data
     */
    var pricingControlsAttributeHandler: (SelectedPriceState) -> Void {
        
        return { selectedPrice in
            
            switch selectedPrice {
            case .bundlePrice:
                
                //Show bundle pricing information
                self.pricingInformationSc.selectedSegmentIndex = SelectedPriceState.bundlePrice.rawValue
                self.onDisplayPriceTypeInformation(self.pricingInformationSc)
                
                //Display the price type chosen
                self.priceSwitchController?.selectPriceType(priceType: .bundle)
                
                //Enable stepper of bundle price in pricing information
                self.bundleQtyStepper.isEnabled = true
                
            case .unitPrice:
                
                //Show unit pricing information
                self.pricingInformationSc.selectedSegmentIndex = SelectedPriceState.unitPrice.rawValue
                self.onDisplayPriceTypeInformation(self.pricingInformationSc)
                
                //Display the price type chosen
                self.priceSwitchController?.selectPriceType(priceType: .unit)
                
                //Disable stepper of bundle price in pricing information
                self.bundleQtyStepper.isEnabled = false
            }
        }
        
    }
    
    // MARK: - Create, Read, Update, Delete
    
    
    
    func processOnDone() {
        let onSaveEventHandler = ValidationListItemState.OnSaveListItemEventHandler(validate: { currentState in
            
            let isNameValid = self.validateItemField(currentState: currentState)
            let isCurrencyCodeValid = self.validateCurrencyCode()
            
            return isNameValid && isCurrencyCodeValid
            
        }, actionIfValidateTrue: {currentState in
            
            switch currentState {
                
            case .newListItem:
                self.saveNewLineItem()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "back to shopping list", sender: self)
                
            case .existingListItem:
                self.saveUpdateListItem()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        })
        
        validationListItemState.handle(event: .onSaveListItem(onSaveEventHandler), handleNextStateUiAttributes: nil)
    }
    
    /**
     Save new item
     */
    fileprivate func saveNewLineItem() {
        
        let moc = persistentContainer.viewContext
        
        do {
            let isExist = try Item.isNameExist(itemNameTextField.text!, moc: moc)
            
            if !isExist {
                
                item = Item(context: moc)
            }
            
            
            item?.name = itemNameTextField.text!
            item?.brand = brandTextField.text
            item?.countryOfOrigin = countryOriginTextField.text
            item?.itemDescription = descriptionTextField.text
            processPictureOnDone(of: item!, in: moc)
            updateUnitPrice(of: item!)
            updateBundlePrice(of: item!)
            
            let shoppingLineItem = shoppingList.add(item: item!, quantity: quantityToBuyStepperConvert)
            
            shoppingLineItem.priceTypeSelectedConvert = selectedPriceState.rawValue
            
            try persistentContainer.viewContext.save()
            
            //The following is needed to update the prices in the shopping list table view controller
            persistentContainer.viewContext.refresh(shoppingLineItem, mergeChanges: true)
            
        } catch  {
            
            let nserror = error as NSError
            
            if let validationError = nserror.userInfo[AnyHashable("NSValidationErrorKey")] {
                
                displayErrorValuesFollowup(fieldName: validationError as! String)
                
            }
        }
    }
    
    func displayErrorValuesFollowup(fieldName: String) {
        
        let title = "You forgot to give a " + fieldName
        
        let nameAlertVc = UIAlertController(title: title, message: "Provide the following", preferredStyle: .alert)
        nameAlertVc.addTextField(configurationHandler: { nameTextField in
            nameTextField.placeholder = "Name for item"
        })
        
        let doneAction = UIAlertAction(title: "Save", style: .default, handler: { alertAction in
            
            let name = nameAlertVc.textFields?.first?.text
            self.itemNameTextField.text = name ?? ""
            
            self.processOnDone()
            
        })
        
        nameAlertVc.addAction(doneAction)
        nameAlertVc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {alertAction in
            
            
            self.persistentContainer.viewContext.rollback()
            
        }))
        
        present(nameAlertVc, animated: true, completion: nil)
    }
    
    /**
     Save existing item
     */
    fileprivate func saveUpdateListItem() {
        
        let moc = persistentContainer.viewContext
        
        processPictureOnDone(of: (shoppingListItem?.item)!, in: moc)
        shoppingListItem?.item?.name = itemNameTextField.text
        shoppingListItem?.item?.countryOfOrigin = countryOriginTextField.text
        shoppingListItem?.item?.brand = brandTextField.text
        shoppingListItem?.item?.itemDescription = descriptionTextField.text
        shoppingListItem?.quantityToBuyConvert = quantityToBuyStepperConvert
        shoppingListItem?.priceTypeSelectedConvert = selectedPriceState.rawValue
        print(">>>>\(#function) - \(selectedPriceState.rawValue)")
        
        updateUnitPrice(of: (shoppingListItem?.item)!)
        updateBundlePrice(of: (shoppingListItem?.item)!)
        
        do {
            if let hasChanges = shoppingListItem?.managedObjectContext?.hasChanges, hasChanges {
                try shoppingListItem?.managedObjectContext?.save()
            }
            
            //The following is needed to update the prices in the shopping list table view controller
            if shoppingListItem != nil {
                persistentContainer.viewContext.refresh(shoppingListItem!, mergeChanges: true)
            }
        } catch  {
            
            let nserror = error as NSError
            
            if let validationError = nserror.userInfo[AnyHashable("NSValidationErrorKey")] {
                
                displayErrorValuesFollowup(fieldName: validationError as! String)
                
            }
        }
    }
    
    private func updateUnitPrice(of item: Item) {
        
        if unitPrice == nil {
            //Create new price
            unitPrice = Price(context: persistentContainer.viewContext)
            item.addToPrices(unitPrice!)
        }
        
        unitPrice?.currencyCode = unitCurrencyCodeField.text ?? userLocale.currencyCode
        unitPrice?.quantityConvert = 1
        unitPrice?.valueConvert = unitPriceVc ?? 0
        unitPrice?.type = 0
    }
    
    private func updateBundlePrice(of item: Item) {
        
        if bundlePrice == nil {
            //New bundle price
            bundlePrice = Price(context: persistentContainer.viewContext)
            item.addToPrices(bundlePrice!)
        }
        let t = bundleCurrencyCodeTextField.text
        print("\(t!)")
        bundlePrice?.currencyCode = bundleCurrencyCodeTextField.text ?? userLocale.currencyCode
        bundlePrice?.valueConvert = bundlePriceVc ?? 0
        bundlePrice?.quantityConvert = bundleQtyPricingInfoVc ?? 2
        bundlePrice?.type = 1
    }
    
    private func deleteItemFromShoppingList() {
        
        //THe following is wrong. We do not want to delete the picture from filesystem because other shopping list is affected.
//        if let stringPath = shoppingListItem?.item?.picture?.fileUrl {
//            deletePicture(at: stringPath)
//        }
        
        let moc = persistentContainer.viewContext
        
        moc.delete(shoppingListItem!)
        
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Error \(nserror) : \(nserror.userInfo)")
        }
    }
    
    // MARK: - User events
    
    /**
     Starts the validation and saving process
     */
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        
        processOnDone()
    }
    
    /**
     The logic depends on the state of the selected price type. The event of selecting the price type configures the behavior of the stepper to respond differently depending on selected price type.
     */
    @IBAction func onChangeQtyToBuy(_ sender: UIStepper) {
        
        selectedPriceState.transition(event: .onChangeQtyToBuy(onChangeQtyToBuyEventHandler), handleStateUiAttribute: pricingControlsAttributeHandler)
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
    }
    
    @IBAction func onDeleteItem(_ sender: UIButton) {
        
        validationListItemState.handle(event: .onDeleteListItem({ state in
            
            switch state {
                
            case .existingListItem:
                self.deleteItemFromShoppingList()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
            
        }), handleNextStateUiAttributes: nil)
    }
    
    @IBAction func onPictureAction(_ sender: UIButton) {
        
        //Create a action sheet
        let pictureActionSheetController = pictureActionSheet
        
        //The following will cause app to adapt to iPad by presenting action sheet as popover on an iPad.
        pictureActionSheetController.modalPresentationStyle = .popover
        let popoverMenuPresentationController = pictureActionSheetController.popoverPresentationController
        popoverMenuPresentationController?.sourceView = sender
        popoverMenuPresentationController?.sourceRect = sender.frame
        present(pictureActionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - State: Handle validation state transition and state-based ui properties
    
    func validateCurrencyCode() -> Bool {
        
        guard let unitCurrencyCode = unitCurrencyCodeField.text, CurrencyHelper().isValid(currencyCode: unitCurrencyCode) else {
            let alert = UIAlertController(title: "Unit price currency code is invalid", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            //Reinstate back the original currency code
            unitCurrencyCodeField.text = unitPrice?.currencyCode
            
            return false
        }
        
        guard let bundleCurrencyCode = bundleCurrencyCodeTextField.text, CurrencyHelper().isValid(currencyCode: bundleCurrencyCode) else {
            let alert = UIAlertController(title: "Bundle price currency code is invalid", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            //Reinstate back the original currency code
            bundleCurrencyCodeTextField.text = bundlePrice?.currencyCode
            
            return false
        }
        
        return true
    }
    
    func validateItemField(currentState: ValidationListItemState) -> Bool {
        
        //Validate currency code for both existing and new
        
        if let name = self.itemNameTextField.text, !name.isEmpty {
            
            switch currentState {
                
            case .newListItem:
                do {
                    let itemName = self.itemNameTextField.text!
                    
                    if try Item.isNameExist(itemName, moc: self.persistentContainer.viewContext) {
                        
                        if self.validationItemState == .existingItem {
                            return true
                        }
                        
                        print("Item exist. Fetching to show user.")
                        
                        let alert = UIAlertController(title: "Item with name \(name) exist", message: "Fetching \(name) now", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
                            
                            self.item = (try? Item.find(name: itemName, in: self.persistentContainer.viewContext)) ?? nil
                            
                            if self.item != nil {
                                self.validationItemState.handle(event: .onExistingItem)
                            }
                        })
                        
                        alert.addAction(action)
                        
                        self.present(alert, animated: true)
                        
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
            
            self.displayErrorValuesFollowup(fieldName: "name")
            return false
        }
        
    }
    
    lazy var validationStateUiPropertiesHandler: (ValidationListItemState) -> Void = { nextState in
        
        switch nextState {
        case .newListItem:
            self.deleteItemButton.isEnabled = false
            
            let selectedPriceTypeEvent = SelectedPriceState.Event.onSelectPriceType(.unit, nil)
            
            self.selectedPriceState.transition(event: selectedPriceTypeEvent, handleStateUiAttribute: self.pricingControlsAttributeHandler)
            
        case .existingListItem:
            
            self.item = self.shoppingListItem?.item
            
            self.quantityToBuyStepper.value = Double((self.shoppingListItem?.quantityToBuyConvert) ?? 1)
            
            self.pictureState.transition(event: .onLoad(self.shoppingListItem?.item?.picture?.fileUrl), handleNextStateUiAttributes: self.nextPictureStateUiAttributes)
            
            //Contains a property observer that set the price fields
            self.prices = self.shoppingListItem?.item?.prices
            
            self.deleteItemButton.isEnabled = true
            
            let priceTypeVal = self.shoppingListItem?.priceTypeSelectedConvert ?? PriceType.unit.rawValue
            let savedSelectedPriceType = PriceType(rawValue:priceTypeVal)!
            
            
            //Store the quantity to buy in a special var, depending on the price type chosen
            switch savedSelectedPriceType {
                
            case .unit:
                self.quantityToBuyAtUnit = self.shoppingListItem?.quantityToBuyConvert ?? 1
            case .bundle:
                self.quantityToBuyAtBundle = self.shoppingListItem?.quantityToBuyConvert ?? 2
            }
            
            //Event handler for shopping list item will set the proper quantity value and selected price type. Do not set anywhere else.
            let selectedPriceTypeEvent = SelectedPriceState.Event.onSelectPriceType(savedSelectedPriceType, self.onSelectPriceTypeEventHandler)
            
            self.selectedPriceState.transition(event: selectedPriceTypeEvent, handleStateUiAttribute: self.pricingControlsAttributeHandler)
            
        default:
            break
        }
    }
    
    // MARK: - Populate values for user interface controls
    
    /**
     Populate item fields and its associated prices
     */
    func populateItemFields(item: Item?) {
        itemNameTextField?.text = item?.name
        brandTextField?.text = item?.brand
        countryOriginTextField?.text = item?.countryOfOrigin
        descriptionTextField?.text = item?.itemDescription
        
        prices = item?.prices
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    @IBAction func onReceiveUnwind(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier, identifier == "unwind to shopping list item editor" {
            let searchVc = segue.source as! SearchItemsTableViewController
            item = searchVc.selectedItem
            changeState.transition(event: .onSearchResult, handleNextStateUiAttributes: changeStateAttributeHandler)
            validationItemState.handle(event: .onExistingItem)
            pictureState.transition(event: .onLoad(item?.picture?.fileUrl), handleNextStateUiAttributes: nextPictureStateUiAttributes)
        }
    }
    
    @IBAction func onPickPicture(_ sender: UITapGestureRecognizer) {
        
        //Create a action sheet
        let pictureActionSheetController = pictureActionSheet
        
        //The following will cause app to adapt to iPad by presenting action sheet as popover on an iPad.
        pictureActionSheetController.modalPresentationStyle = .popover
        let popoverMenuPresentationController = pictureActionSheetController.popoverPresentationController
        popoverMenuPresentationController?.sourceView = itemImageView
        popoverMenuPresentationController?.sourceRect = itemImageView.bounds
        present(pictureActionSheetController, animated: true, completion: nil)
    }
}

// MARK: - State: Handle picture actions and states

extension ShoppingListItemEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pictureActionSheet: UIAlertController {
        //Create a action sheet
        let pictureActionSheet = UIAlertController(title: "Show a picture of the item", message: nil, preferredStyle: .actionSheet)
        
        //HIG: A Cancel button instills confidence when the user is abandoning a task. Cancel button will not be displayed in iPad.
        pictureActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        switch pictureState {
        case .none, .delete:
            break
        default:
            //HIG: Make destructive choices prominent. Use red for buttons that perform destructive or dangerous actions, and display these buttons at the top of an action sheet.
            pictureActionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: onPictureActionHandler))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pictureActionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: onPictureActionHandler))
        }
        
        pictureActionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: onPictureActionHandler))
        
        return pictureActionSheet
    }
    
    var onPictureActionHandler: (UIAlertAction) -> Void {
        get {
            return { action in
                switch action.title! {
                case "Camera":
                    self.activateImagePicketController(sourceType: .camera)
                    
                case "Album":
                    self.activateImagePicketController(sourceType: .savedPhotosAlbum)
                    
                case "Delete":
                    self.pictureState.transition(event: .onDelete, handleNextStateUiAttributes: self.nextPictureStateUiAttributes)
                    self.changeState.transition(event: .onDeletePicture, handleNextStateUiAttributes: self.changeStateAttributeHandler)
                default:
                    break
                }
            }
        }
    }
    
    /**
     Handles the setting of properties for UIImage depending on state. State machine will pass the image to this closure.
     */
    var nextPictureStateUiAttributes: (PictureState, ItemPicture?) -> Void {
        
        return { (pictureState: PictureState, itemPicture: ItemPicture?) -> Void in
            
            switch pictureState {
                
            case .delete, .none:
                let placeholder = UIImage(named: "ic_add_a_photo")!
                self.itemImageView.image = PictureUtil.resizeImage(image: placeholder, newWidth: self.itemImageView.bounds.width, newHeight: self.itemImageView.bounds.width)
                
            case .new, .replacement:
                self.itemImageVc = itemPicture
                self.itemImageView.image = self.itemImageVc?.scale(widthToScale: self.itemImageView.bounds.width)
                
            case .existing:
                self.itemImageVc = itemPicture
                self.itemImageView.image = self.itemImageVc?.scale(widthToScale: self.itemImageView.bounds.width)
                
            default:
                break
            }
            
        }
    }
    
    /**
     Depending on picture state, the image file will either be written/deleted to/from app document folder
     */
    func processPictureOnDone(of item: Item, in moc: NSManagedObjectContext) {
        
        pictureState.transition(event: .onSaveImage({ pictureState in
            
            switch pictureState {
                
            case .none:
                break
                
            case .new:
                self.savePictureInFilesystemAndCoreData(of: item, in: moc)
                
            case .replacement:
                
                if let filename = item.picture?.fileUrl {
                    
                    //Delete existing picture from document folder
                    self.deletePicture(at: filename)
                    
                    //Delete existing picture from database
                    moc.delete(item.picture!)
                    
                    self.savePictureInFilesystemAndCoreData(of: item, in: moc)
                }
                
            case .delete:
                
                if let filename = item.picture?.fileUrl {
                    
                    //Delete existing picture from document folder
                    self.deletePicture(at: filename)
                    
                    //Delete picture from database
                    moc.delete(item.picture!)
                }
                
            default:
                break
            }
        }))
    }
    
    func savePictureInFilesystemAndCoreData(of item: Item, in moc: NSManagedObjectContext) {
        
        let stringFilename = writeImagePickedFromCameraToFile()
        
        if let stringFilename = stringFilename {
            let newPicture = Picture(context: moc)
            newPicture.fileUrl = stringFilename
            item.picture = newPicture
        }
    }
    
    func writeImagePickedFromCameraToFile() -> String? {
        
        if let image = itemImageVc?.fullScaleImage {
            let cameraUtil = CameraUtil()
            return cameraUtil.writeImageToFileSystem(data: image)
        } else {
            return nil
        }
    }
    
    /**
     Delete picture from app document folder
     - Parameter filename: Does not contain any directory or folder
     */
    func deletePicture(at filename: String) {
        let fileMgr = FileManager.default
        let fileUrl = PictureUtil.pictureinDocumentFolder(filename: filename)
        
        do {
            try fileMgr.removeItem(at: fileUrl)
        } catch {
            let nserror = error as NSError
            print("\(#function) Failed to delete existing picture \(filename) -> \(nserror): \(nserror.userInfo)")
        }
        
    }
    
    func activateImagePicketController(sourceType: UIImagePickerControllerSourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        if sourceType == .camera {
            imagePickerController.cameraCaptureMode = .photo
        }
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let selectedOriginalItemImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        pictureState.transition(event: .onFinishPickingCameraMedia(selectedOriginalItemImage), handleNextStateUiAttributes: nextPictureStateUiAttributes)
        
        changeState.transition(event: .onCameraCapture, handleNextStateUiAttributes: changeStateAttributeHandler)
        
        self.dismiss(animated: true, completion: { print("completion dismiss imagePickerVc")})
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Handle change state transition event action and ui attributes
extension ShoppingListItemEditorViewController: UITextFieldDelegate {
    
    
    var changeStateAttributeHandler: (ChangeState) -> Void {
        return { changeState in
            
            switch changeState {
                
            case .changed:
                self.doneButton.isEnabled = true
                
            default:
                break
            }
            
        }
    }
    
    var changeStateOnCancelEventAction: (ChangeState) -> Void {
        return { (changeState: ChangeState) -> Void  in
            
            switch changeState {
                
            case .unchanged:
                
                self.performSegue(withIdentifier: "return to shopping list", sender: self)
                
            case .changed:
                //Alert vc will adapt. iPad will show as popover. iPhone present modally from bottom.
                let alertVc = UIAlertController(title: "Warning", message: "You may have unsaved change(s)", preferredStyle: .actionSheet)
                
                //Apple HIG
                alertVc.addAction(UIAlertAction(title: "Leave", style: .destructive) {
                    action in
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                })
                
                alertVc.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
                alertVc.modalPresentationStyle = .popover
                let ppc = alertVc.popoverPresentationController
                ppc?.barButtonItem = self.cancelButton
                
                self.present(alertVc, animated: true, completion: nil)
                
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
        
        validationListItemState.handle(event: .onChangeCharacters, handleNextStateUiAttributes: nil)
        
        return true
    }
}
