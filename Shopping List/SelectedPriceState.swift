//
//  SelectedPriceState.swift
//  Shopping List
//
//  Created by Mirza Irwan on 12/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum SelectedPriceState: Int {
    
    case unitPrice = 0
    case bundlePrice = 1
    
    enum Event {
        case onSelectPriceType(PriceType, ((PriceType) -> Void)?)
        case onChangeQtyToBuy((SelectedPriceState) -> Void)

        case onBundleQtyChange(Int, (SelectedPriceState, Int) -> Void)
    }
    
    init() {
        self = .unitPrice
    }
    
    mutating func transition(event: Event, handleStateUiAttribute: ((SelectedPriceState) -> Void)? = nil) {
        
        switch self {
            
        case .unitPrice:
            switch event {
                
            case .onSelectPriceType(let priceType, let eventHandler):
                eventHandler?(priceType)
                if priceType == .bundle {
                    self = .bundlePrice
                }
                
            case .onChangeQtyToBuy(let eventHandler):
                eventHandler(self)
                
            case .onBundleQtyChange(let bundleQty, let eventHandler):
                eventHandler(self, bundleQty)
                
            }
            
        case .bundlePrice:
            switch event {
                
            case .onSelectPriceType(let priceType, let eventHandler):
                eventHandler?(priceType)
                if priceType == .unit {
                    self = .unitPrice
                }
                
            case .onChangeQtyToBuy(let eventHandler):
                eventHandler(self)
                
            case .onBundleQtyChange(let bundleQty, let eventHandler):
                eventHandler(self, bundleQty)
                
            }
        }
        
        handleStateUiAttribute?(self)
        
    }
}
