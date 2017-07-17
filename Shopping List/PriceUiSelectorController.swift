//
//  PriceUiSelectorUiController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 17/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

struct PriceUiSelectorController {
    
    private let unitPrice: (switch: UISwitch, label: UILabel)
    private let bundlePrice: (switch: UISwitch, label: UILabel)
    
    init(unitPriceUi: (switch: UISwitch, label: UILabel),
         bundlePriceUi: (switch: UISwitch, label: UILabel)) {
        self.unitPrice = unitPriceUi
        self.bundlePrice = bundlePriceUi
        self.unitPrice.switch.isOn = true
        self.bundlePrice.switch.isOn = false
    }
    
    func selectPriceType(priceType: PriceType) {
        switch priceType {
        case .unit:
            unitPrice.switch.isOn = true
            unitPrice.label.textColor = UIColor.darkGray
            bundlePrice.switch.isOn = false
            bundlePrice.label.textColor = UIColor.lightGray
            
            
        case .bundle:
            unitPrice.switch.isOn = false
            unitPrice.label.textColor = UIColor.lightGray
            bundlePrice.switch.isOn = true
            bundlePrice.label.textColor = UIColor.darkGray
        }
    }
}
