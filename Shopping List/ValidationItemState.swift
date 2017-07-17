//
//  ValidationItemState.swift
//  Shopping List
//  handles the state of an item
//
//  Created by Mirza Irwan on 17/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum ValidationItemState {
    case transient
    case existingItem
    case newItem
    
    enum Event {
        case onNewItem
        case onExistingItem
    }
    
    init() {
        self = .transient
    }
    
    mutating func handle(event: ValidationItemState.Event, handleNextStateUiAttributes: ((ValidationItemState) -> Void)? = nil) {
        
        switch self {
            
        case .transient:
            
            switch event {
                
            case .onExistingItem:
                self = .existingItem
                
            default:
                self = .newItem
            }
            
            
        default:
            break
            
            
        }
    }
    
}
