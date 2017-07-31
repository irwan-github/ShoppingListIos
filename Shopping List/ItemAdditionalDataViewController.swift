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
    
    // MARK: - Item information
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var countryOfOriginLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var unitCurrencyCode: UILabel!
    @IBOutlet weak var bundleCurrencyCode: UILabel!
    @IBOutlet weak var unitPriceTranslate: UILabel!
    @IBOutlet weak var bundlePriceTranslate: UILabel!
    
    // MARK: - Item pricing information
    
    @IBOutlet weak var unitCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var unitPriceLabel: UILabel!
    
    @IBOutlet weak var bundleCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var bundlePriceLabel: UILabel!
    
    @IBOutlet weak var bundleQtyValueLabel: UILabel!
    
    @IBOutlet weak var unitPriceGroup: UIStackView!
    
    @IBOutlet weak var bundlePriceGroup: UIStackView!
    
    var unitPrice: Price?
    
    var bundlePrice: Price?
    
    /**
     Consist of unit price and bundle price. Set property observer to populate price fields.
     */
    private var prices: NSSet? {
        didSet {
            if let prices = prices {
                unitPrice = Price.filterSet(of: prices, match: .unit)
                unitPriceVc = unitPrice?.valueConvert
                unitCurrencyCode?.text = unitPrice?.currencySymbol
                
                bundlePrice = Price.filterSet(of: prices, match: .bundle)
                bundlePriceVc = bundlePrice?.valueConvert
                bundleQtyVc = bundlePrice?.quantityConvert
                bundleCurrencyCode?.text = bundlePrice?.currencySymbol
            }
        }
    }
    
    /**
     Currency-formatted pricing information for unit price. Acts as a adapter to Price model which stores data as type Int32. Set property observer to populate unit price field.
     */
    private var unitPriceVc: Int? {
        didSet {
            
            if let unitPriceVc = unitPriceVc {
                unitPriceLabel?.text = Helper.string(from: unitPriceVc, fractionDigits: 2)
                
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
                bundlePriceLabel?.text = Helper.string(from: bundlePriceVc, fractionDigits: 2)
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
    
    //Get the user's home currency code
    private let homeCurrencyCode = CurrencyHelper().getHomeCurrencyCode() ?? Locale.current.currencyCode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUi()
        
        if !isExchangeRateRequired {
            self.unitPriceTranslated = nil
            self.bundlePriceTranslated = nil
            return
        }
        
        let exchangeRateWebApi = ExchangeRateWebApi()
        
        exchangeRateWebApi.getExchangeRates(completionHandlerForMain: { exchangeRates in
            
            if let exchangeRates = exchangeRates {
                
                if let unitPrice = self.unitPrice, unitPrice.currencyCode! != self.homeCurrencyCode {
                    guard let rate = exchangeRates[(unitPrice.currencyCode)!] else { return }
                    self.setTranslatedPrice(type: .unit, price: unitPrice, rate: rate)
                } else {
                    self.unitPriceTranslated = nil
                }
                
                if let bundlePrice = self.bundlePrice, bundlePrice.currencyCode! != self.homeCurrencyCode {
                    guard let rate = exchangeRates[(bundlePrice.currencyCode)!] else { return }
                    self.setTranslatedPrice(type: .bundle, price: bundlePrice, rate: rate)
                } else {
                    self.bundlePriceTranslated = nil
                }
            }
        })
    }
    
    private var isExchangeRateRequired: Bool {
    
        if let unitCurrencyCode = unitPrice?.currencyCode, unitCurrencyCode != homeCurrencyCode {
            return true
        }
        
        if let bundleCurrencyCode = bundlePrice?.currencyCode, bundleCurrencyCode != homeCurrencyCode {
            return true
        }
        
        return false
    }
    
    var unitPriceTranslated: String? {
        didSet {
            unitPriceTranslate.text = unitPriceTranslated
        }
    }
    
    var bundlePriceTranslated: String? {
        didSet {
            bundlePriceTranslate.text = bundlePriceTranslated
        }
    }
    
    private func setTranslatedPrice(type: PriceType, price: Price, rate: Double) {
        
        let priceTranslateText: String?
        
        let exchangeRate = ExchangeRate(foreignCurrencyCode: self.unitPrice?.currencyCode, costInForeignCurrencyToGetOneUnitOfBaseCurrency: rate)
        
        let priceFcDouble = Double(price.valueConvert) / 100
        
        let priceFcDoubleConverted = exchangeRate.convert(foreignAmount: priceFcDouble)
        
        if let priceFcDoubleConverted = priceFcDoubleConverted {
            priceTranslateText = "(" + priceFcDoubleConverted + ")"
        } else {
            priceTranslateText = nil
        }
        
        if type == .unit {
            unitPriceTranslated = priceTranslateText
        }
        
        if type == .bundle {
            bundlePriceTranslated = priceTranslateText
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set preferred content size if this is a popover presentation
        preferredContentSize = calculatePreferredContentSize()
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
    
    func actionOnDoneAdditionalInfo() {
        print("\(#function) - \(type(of: self))")
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var priceInfoStackView: UIStackView!
    @IBOutlet weak var bundleQtyStackView: UIStackView!
    
    func calculatePreferredContentSize() -> CGSize {
        
        let offsetForLastViewInBundleQtyStackView = bundleQtyStackView.frame.origin.y + (bundleQtyStackView.subviews.last?.frame.origin.y ?? 0) + (bundleQtyStackView.subviews.last?.frame.height ?? 0)
        return CGSize(width: 0, height: priceInfoStackView.frame.origin.y + offsetForLastViewInBundleQtyStackView)
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
