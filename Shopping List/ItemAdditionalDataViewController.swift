//
//  ItemAdditionalDataViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 16/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class ItemAdditionalDataViewController: UIViewController {
    
    //MARK: - API & Model
    
    var item: Item? {
        didSet {
            updateUi()
        }
    }
    
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var countryOfOriginLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Item pricing information
    
    @IBOutlet weak var unitCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var unitPriceLabel: UILabel!
    
    @IBOutlet weak var bundleCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var bundlePriceLabel: UILabel!
    
    @IBOutlet weak var bundleQtyValueLabel: UILabel!
    
    @IBOutlet weak var unitPriceGroup: UIStackView!
    
    @IBOutlet weak var bundlePriceGroup: UIStackView!
    
    /**
     Consist of unit price and bundle price. Set property observer to populate price fields.
     */
    private var prices: NSSet? {
        didSet {
            if let prices = prices {
                let unitPrice = Price.filterSet(of: prices, match: .unit)
                unitPriceVc = unitPrice?.valueConvert
                
                let bundlePrice = Price.filterSet(of: prices, match: .bundle)
                bundlePriceVc = bundlePrice?.valueConvert
                bundleQtyVc = bundlePrice?.quantityConvert
                
            }
        }
    }
    
    /**
     Currency-formatted pricing information for unit price. Acts as a adapter to Price model which stores data as type Int32. Set property observer to populate unit price field.
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
     Currency-formatted pricing information for bundle. Functions as a adapter to Price model which stores data as type Int32. Set property observer to populate bundle price fielda.
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
    
    /**
     Pricing information for bundle.
     Converts Double to Int for getter.
     Set value of bundleQtyLabel.text after converting Double to String.
     */
    private var bundleQtyVc: Int? {
        didSet {
            let setValue = bundleQtyVc ?? 2
            bundleQtyValueLabel?.text = String(describing: setValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUi()
        // Do any additional setup after loading the view.
    }
    
    func updateUi() {
        brandLabel?.text = item?.brand
        countryOfOriginLabel?.text = item?.countryOfOrigin
        descriptionLabel?.text = item?.itemDescription
        
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
            
            unitPriceGroup?.isHidden = false
            bundlePriceGroup?.isHidden = true
            
        case .bundle:
            
            bundlePriceGroup?.isHidden = false
            unitPriceGroup?.isHidden = true
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
