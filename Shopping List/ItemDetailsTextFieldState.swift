//
//  ItemDetailsTextFieldState.swift
//  Shopping List
//
//  Created by Mirza Irwan on 27/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum ItemDetailsTextFieldState: Int {
    
    case transient = -1
    case nameTag = 0
    case brandTag
    case countryTag
    case descriptionTag
    
    enum Event {
        case onLoad(Int)
        case shouldBeginEditing(Int)
        case shouldReturn
        case didEndEditing
        case endEditing
    }
    
    init() {
        self = .transient
    }
    
    mutating func next(event: Event, completionHandler: ((ItemDetailsTextFieldState) -> Void)?) {
        
        switch event {
            
        case .onLoad(let state):
            
            guard let stateInd = ItemDetailsTextFieldState(rawValue: state) else { break }
            
            switch self {
                
            case .transient:
                self = stateInd
                
            default:
                break
                
            }
            
            
        case .shouldBeginEditing(let state):
            
            guard let stateInd = ItemDetailsTextFieldState(rawValue: state) else { break }
            
            switch stateInd {
                
            case .nameTag:
                self = .nameTag
                
            case.brandTag:
                self = .brandTag
                
            case .countryTag:
                self = .countryTag
                
            case .descriptionTag:
                self = .descriptionTag
                
            default:
                break
            }
            
        case .shouldReturn:
            
            switch self {
                
            case .nameTag:
                self = .brandTag
                
            case.brandTag:
                self = .countryTag
                
            case .countryTag:
                self = .descriptionTag
                
            case .descriptionTag:
                self = .transient
                
            default:
                break
            }
            
        case .endEditing:
            self = .transient
            
        default:
            break
        }
        
        completionHandler?(self)
    }
}
