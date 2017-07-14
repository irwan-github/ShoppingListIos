//
//  ItemBaseViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 14/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {
    
    // MARK: - API and Model
    
    var shoppingListItem: ShoppingListItem? {
        didSet {
            item = try! Item.find(name: (shoppingListItem?.item?.name)!,
                             moc: (shoppingListItem?.managedObjectContext)!)
        }
    }
    
    var item: Item?
    
    var persistentContainer: NSPersistentContainer? = AppDelegate.persistentContainer
    
    // MARK: - Properties
    
    // MARK: - Item Basic information
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var itemBrandLabel: UILabel!
    
    @IBOutlet weak var itemCountryLabel: UILabel!
    
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    // MARK: - Item pricing information
    
    private var prices: NSSet? {
        didSet {
            if let prices = prices {
                unitPrice = Price.filterSet(of: prices, match: .unit)
                unitPriceVc = unitPrice?.valueConvert
                
                bundlePrice = Price.filterSet(of: prices, match: .bundle)
                bundlePriceVc = bundlePrice?.valueConvert
                bundleQtyPricingInfoVc = bundlePrice?.quantityConvert
                
            }
        }
    }
    
    /**
     Pricing information for bundle.
     Converts Double to Int for getter.
     Set value of bundleQtyLabel.text after converting Double to String.
     */
    private var bundleQtyPricingInfoVc: Int? {
        didSet {
            let setValue = bundleQtyPricingInfoVc ?? 2
            bundleQtyValueLabel?.text = String(describing: setValue)
        }
    }
    
    private var unitPrice: Price?
    
    private var bundlePrice: Price?
    
    @IBOutlet weak var pricingInformationSc: UISegmentedControl!
    
    @IBOutlet weak var unitCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var unitPriceLabel: UILabel!
    
    @IBOutlet weak var bundleCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var bundlePriceLabel: UILabel!
    
    @IBOutlet weak var bundleQtyLabel: UILabel!
    
    @IBOutlet weak var bundleQtyValueLabel: UILabel!
    
    @IBOutlet weak var unitPriceGroup: UIStackView!

    @IBOutlet weak var bundlePriceGroup: UIStackView!
    
    /**
     Pricing information for unit
     */
    private var unitPriceVc: Int? {
        didSet {
            
            if let unitPriceVc = unitPriceVc {
                unitPriceLabel?.text = Helper.formatMoney(amount: unitPriceVc)
            } else {
                unitPriceLabel?.text = nil
            }
        }
    }
    
    /**
     Pricing information for bundle
     */
    private var bundlePriceVc: Int? {
        didSet {
            
            if let bundlePriceVc = bundlePriceVc {
                bundlePriceLabel?.text = Helper.formatMoney(amount: bundlePriceVc)
            } else {
                bundlePriceLabel?.text = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        updateUi()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(#function) - \(type(of: self))")
        //updateUi()
    }
    
    func updateUi() {
        
        itemNameLabel?.text = item?.name
        itemBrandLabel?.text = item?.brand
        itemCountryLabel?.text = item?.countryOfOrigin
        itemDescriptionLabel?.text = item?.itemDescription
        prices = item?.prices
        onDisplayPriceTypeInformation(priceType: .unit)
    }
    
    @IBAction func onSelectPriceInformation(_ sender: UISegmentedControl) {
            let priceIndicator = sender.selectedSegmentIndex
            onDisplayPriceTypeInformation(priceType: PriceType(rawValue: priceIndicator) ?? .unit)
    }
    
    func onDisplayPriceTypeInformation(priceType: PriceType) {
        
            switch priceType {
            case .unit:
                
                unitPriceGroup.isHidden = false
                bundlePriceGroup.isHidden = true
                
            case .bundle:
                
                bundlePriceGroup.isHidden = false
                unitPriceGroup.isHidden = true
            }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var viewController = segue.destination
        
        if let viewControllerAsNavigationController = viewController as? UINavigationController {
            viewController = viewControllerAsNavigationController.visibleViewController!
        }
        
        if segue.identifier == "Shopping List Item Editor" {
            let shoppingListEditorVc = viewController as! ShoppingListItemEditorViewController
            shoppingListEditorVc.shoppingListItem = shoppingListItem
        }
    }
    
    
}
