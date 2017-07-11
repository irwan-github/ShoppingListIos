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
    
    var shoppingListItem: ShoppingListItem?
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    // MARK: - Properties
    private var prices: [Price]? {
        didSet {
            unitPriceDisplay = unitPrice?.valueDisplay
            bundlePriceDisplay = bundlePrice?.valueDisplay
            
            if let bundlePrice = bundlePrice {
                bundleQtyStepper.value = Double(bundlePrice.quantityDisplay)
                bundleQtyDisplay = bundlePrice.quantityDisplay
                
            } else {
                bundleQtyStepper.value = Double(2)
                bundleQtyDisplay = 2
            }
            
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
    
    fileprivate var validationState = ValidationState()
    
    fileprivate var changeState = ChangeState()
    
    fileprivate var pictureState = PictureState()
    
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
    
    private var bundleQtyDisplay: Int? {
        set {
            let setValue = newValue ?? 2
            bundleQtyLabel.text = String(describing: setValue)
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
    
    fileprivate var itemImage: UIImage? {
        didSet {
            itemImageView.image = itemImage
        }
    }
    
    @IBOutlet weak var itemImageView: UIImageView!
    
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
        
        if shoppingListItem == nil {
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
                    
                    self.itemNameTextField.text = self.shoppingListItem?.item?.name
                    self.brandTextField.text = self.shoppingListItem?.item?.brand
                    self.quantityToBuyDisplay = (self.shoppingListItem?.quantity)!
                    self.quantityToBuyStepper.value = Double((self.shoppingListItem?.quantity)!)
                    self.countryOriginTextField.text = self.shoppingListItem?.item?.countryOfOrigin
                    self.descriptionTextField.text = self.shoppingListItem?.item?.itemDescription
                    self.pictureState.transition(event: .onExist, handleNextStateUiAttributes: self.nextPictureStateUiAttributes)
                    
                    //Although I can traverse from item to get prices of type NSSet, it is difficult to work with NSSet.
                    //Therefore I do a fetch prices to get an array of prices at the cost of a round trip to database
                    self.prices = try! Price.findPrices(of: (self.shoppingListItem?.item)!, moc: self.persistentContainer.viewContext)
                    
                    if let selected = self.shoppingListItem?.priceTypeSelected {
                        self.priceTypeSc.selectedSegmentIndex = Int(selected)
                    } else {
                        self.priceTypeSc.selectedSegmentIndex = Int(PriceType.unit_price.rawValue)
                    }
                    
                    self.onDisplayPriceTypeInformation(self.priceTypeSc)
                    self.itemNameTextField.isEnabled = false
                    self.deleteItemButton.isHidden = false
                    self.selectedPrice = (self.shoppingListItem?.priceTypeSelected)!
                    
                default:
                    break
                }
            })
        }
    }
    
    @IBAction func onChangeQtyToBuy(_ sender: UIStepper) {
        
        quantityToBuyDisplay = Int(sender.value)
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
    }
    
    @IBAction func onBundleQtyChange(_ sender: UIStepper) {
        
        self.bundleQtyDisplay = Int(sender.value)
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
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
    
    func writePicturePickedFromCameraToFile() -> URL? {
        
        if let image = itemImage {
            let cameraUtil = CameraUtil()
            return cameraUtil.persistImage(data: image)
        } else {
            return nil
        }
    }
    
    /**
     Save new item
     */
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
            handlePictureEventAction(of: item, in: moc)
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
    
    /**
     Save existing item
     */
    fileprivate func saveUpdate() {
        
        let moc = persistentContainer.viewContext
        
        if let shoppingLineItem = shoppingListItem, let item = shoppingLineItem.item {
            
            handlePictureEventAction(of: item, in: moc)
            item.countryOfOrigin = countryOriginTextField.text
            item.brand = brandTextField.text
            item.itemDescription = descriptionTextField.text
            shoppingLineItem.quantity = quantityToBuyDisplay
            shoppingLineItem.priceTypeSelected = selectedPrice
            updateUnitPrice(of: item)
            updateBundlePrice(of: item)
        }
        
        do {
            if let hasChanges = shoppingListItem?.managedObjectContext?.hasChanges, hasChanges {
                try shoppingListItem?.managedObjectContext?.save()
            }
        } catch  {
            let nserror = error as NSError
            print(">>>>Error \(nserror) : \(nserror.userInfo)")
        }
    }
    
    private func updateUnitPrice(of item: Item) {
        
        if let unitPriceDisplay = unitPriceDisplay {
            
            if let unitPrice = unitPrice {
                //Update existing price
                unitPrice.currencyCode = "SGD"
                unitPrice.valueDisplay = unitPriceDisplay
                unitPrice.quantityDisplay = 1
            } else {
                //Create new price
                let unitPrice = Price(context: persistentContainer.viewContext)
                unitPrice.currencyCode = "SGD"
                unitPrice.quantityDisplay = 1
                unitPrice.valueDisplay = unitPriceDisplay
                item.addToPrices(unitPrice)
            }
            
        } else {
            if let unitPrice = unitPrice {
                persistentContainer.viewContext.delete(unitPrice)
            }
        }
    }
    
    private func updateBundlePrice(of item: Item) {
        
        if let bundlePriceDisplay = bundlePriceDisplay {
            
            if let bundlePrice = bundlePrice {
                
                bundlePrice.currencyCode = "SGD"
                bundlePrice.valueDisplay = bundlePriceDisplay
                print("Bundle Qty display \(bundleQtyDisplay ?? -1)")
                bundlePrice.quantityDisplay = bundleQtyDisplay ?? 2
            } else {
                
                let bundlePrice = Price(context: persistentContainer.viewContext)
                bundlePrice.currencyCode = "SGD"
                print("Bundle Qty \(bundleQtyDisplay ?? -1)")
                bundlePrice.quantityDisplay = bundleQtyDisplay ?? 2
                bundlePrice.valueDisplay = bundlePriceDisplay
                print("Bundle Price \(bundlePriceDisplay)")
                item.addToPrices(bundlePrice)
            }
            
        } else {
            
            if let bundlePrice = bundlePrice {
                persistentContainer.viewContext.delete(bundlePrice)
            }
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
        
        if let stringPath = shoppingListItem?.item?.picture?.fileUrl {
            deletePicture(at: stringPath)
        }
        
        let moc = persistentContainer.viewContext
        
        moc.delete(shoppingListItem!)
        
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Error \(nserror) : \(nserror.userInfo)")
        }
    }
    
    // MARK: - Picture
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: - Handle picture actions and states
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
        
        pictureActionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: nil))
        
        return pictureActionSheet
    }
    
    var onPictureActionHandler: (UIAlertAction) -> Void {
        get {
            return { action in
                switch action.title! {
                case "Camera":
                    self.activateCamera()
                case "Delete":
                    self.pictureState.transition(event: .onDelete, handleNextStateUiAttributes: self.nextPictureStateUiAttributes)
                    self.changeState.transition(event: .onDeletePicture, handleNextStateUiAttributes: self.changeStateAttributeHandler)
                default:
                    break
                }
            }
        }
    }

    var nextPictureStateUiAttributes: (PictureState, UIImage?) -> Void {
        
        return { (pictureState: PictureState, newItemPicture: UIImage?) -> Void in
            
            switch pictureState {
                
            case .delete, .none:
                self.itemImage = UIImage(named: "empty-photo")
                
            case .new:
                self.itemImage = newItemPicture!
            
            case .existing:
                if let pictureStringPath = self.shoppingListItem?.item?.picture?.fileUrl {
                    self.itemImage = UIImage(contentsOfFile: pictureStringPath)
                }
                
            case .replacement:
                self.itemImage = newItemPicture!
            }
        }
    }
    
    /**
     Depending on picture state, the image file will either be written/deleted to/from app document folder
     */
    func handlePictureEventAction(of item: Item, in moc: NSManagedObjectContext) {
        
        pictureState.transition(event: .onSaveImage({ pictureState in
            
            switch pictureState {
                
            case .new:
                let itemImageUrl = self.writePicturePickedFromCameraToFile()
                if let itemImageUrl = itemImageUrl {
                    let newPicture = Picture(context: moc)
                    newPicture.fileUrl = itemImageUrl.path
                    item.picture = newPicture
                }
                
            case .replacement:
                
                let fileMgr = FileManager.default
                if let imageStringPath = item.picture?.fileUrl {
                    do {
                        //Delete existing picture from document folder
                        try fileMgr.removeItem(atPath: imageStringPath)
                        
                        //Delete existing picture from database
                        moc.delete(item.picture!)
                        
                        let itemImageUrl = self.writePicturePickedFromCameraToFile()
                        
                        //Create new picture
                        if let itemNewImageUrl = itemImageUrl{
                            let newPicture = Picture(context: moc)
                            newPicture.fileUrl = itemNewImageUrl.path
                            item.picture = newPicture
                        }
                    } catch {
                        let nserror = error as NSError
                        print("\(#function) Failed to delete previous picture from document folder -> \(nserror): \(nserror.userInfo)")
                    }
                }
                
            case .delete:
                let fileMgr = FileManager.default
                if let imageStringPath = item.picture?.fileUrl {
                    do {
                        //Delete existing picture from document folder
                        try fileMgr.removeItem(atPath: imageStringPath)
                        
                        //Delete picture from database
                        moc.delete(item.picture!)
                        
                    } catch {
                        let nserror = error as NSError
                        print("\(#function) Failed to delete existing picture from document folder -> \(nserror): \(nserror.userInfo)")
                    }
                }
                
            default:
                break
            }
        }))
    }
    
    /**
     Delete picture from app document folder
     */
    func deletePicture(at pathString: String) {
        let fileMgr = FileManager.default
        do {
            try fileMgr.removeItem(atPath: pathString)
        } catch {
            let nserror = error as NSError
            print("\(#function) Failed to delete existing picture \(pathString) -> \(nserror): \(nserror.userInfo)")
        }
        
    }
    
    func activateCamera() {
        
        let cameraController = UIImagePickerController()
        cameraController.delegate = self
        cameraController.allowsEditing = false
        cameraController.sourceType = .camera
        cameraController.cameraCaptureMode = .photo
        cameraController.modalPresentationStyle = .fullScreen
        
        present(cameraController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let itemImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        pictureState.transition(event: .onFinishPickingCameraMedia(itemImage), handleNextStateUiAttributes: nextPictureStateUiAttributes)
        
        changeState.transition(event: .onCameraCapture, handleNextStateUiAttributes: changeStateAttributeHandler)
        
        self.dismiss(animated: true, completion: { print("completion dismiss imagePickerVc")})
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        changeState.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateAttributeHandler)
        
        validationState.handle(event: .onChangeCharacters) {
            
            validationState in
            self.itemNameTextField.errorText = nil
        }
        
        return true
    }
}
