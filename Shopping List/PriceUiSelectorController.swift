//
//  PriceUiSelectorUiController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 17/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit


 /// Turns two switches into a simple 2-radio button that are mutually exclusive. The two switches are created by storyboard, so view controller need to have the switches injected as IBOutlets

struct PriceUiSelectorController {
    
    private let unitPrice: (switch: UISwitch, label: UILabel)
    private let bundlePrice: (switch: UISwitch, label: UILabel)
    private var state: PriceType = PriceType.unit
    
    init(unitPriceUi: (switch: UISwitch, label: UILabel),
         bundlePriceUi: (switch: UISwitch, label: UILabel)) {
        self.unitPrice = unitPriceUi
        self.bundlePrice = bundlePriceUi
        
        self.unitPrice.switch.isOn = true
        self.state = PriceType.unit
        self.bundlePrice.switch.isOn = false
    }
    
    mutating func selectPriceType(priceType: PriceType) {
        switch priceType {
        case .unit:
            unitPrice.switch.isOn = true
            state = PriceType.unit
            unitPrice.label.textColor = UIColor.darkGray
            bundlePrice.switch.isOn = false
            bundlePrice.label.textColor = UIColor.lightGray
            
            
        case .bundle:
            unitPrice.switch.isOn = false
            unitPrice.label.textColor = UIColor.lightGray
            bundlePrice.switch.isOn = true
            self.state = PriceType.bundle
            bundlePrice.label.textColor = UIColor.darkGray
        }
    }
    
    // MARK: - Public API
    /**
        Value of selected price type
    */
    var value: PriceType {
        return state
    }
}
