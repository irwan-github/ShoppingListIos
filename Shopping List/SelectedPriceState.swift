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
    
    enum Event: Int {
        case onSelectUnitPrice = 0
        case onSelectBundlePrice = 1
    }
    
    init() {
        self = .unitPrice
    }
    
    mutating func transition(event: Event, handleStateUiAttribute: ((SelectedPriceState) -> Void)? = nil) {
        
        switch self {
            
        case .unitPrice:
            switch event {
            case .onSelectBundlePrice:
                self = .bundlePrice
            default:
                break
            }
            
        case .bundlePrice:
            switch event {
            case .onSelectUnitPrice:
                self = .unitPrice
            default:
                break
            }
        }
        
        handleStateUiAttribute?(self)
        
    }
}
