//
//  TextFieldStateController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 7/8/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

struct TextFieldStateController {
    
    var currTextField: UITextField!
    
    var currState = State()
    
    var handler: ((State) -> Void)?
    
    mutating func next(event: Event) {
        
        switch event {
            
        case .onLoad(let state):
            
            guard let stateInd = State(rawValue: state) else { break }
            
            switch currState {
                
            case .transient:
                currState = stateInd
                
            default:
                break
                
            }
            
            handler?(currState)
            
        //At this point, iOS will display the keyboard
        case .shouldBeginEditing(let textField):
            
            currState = State(rawValue: textField.tag)!
            currTextField = textField
            
        //Define the next textfield the will receive focus
        case .shouldReturn:
            
            switch currState {
                
            case .nameTag:
                currState = .brandTag
                
            case.brandTag:
                currState = .countryTag
                
            case .countryTag:
                currState = .descriptionTag
                
            case .descriptionTag:
                currState = .unitPriceTag
                
            case .unitCurrencyCodeTag:
                currState = .unitPriceTag
                
            case .unitPriceTag:
                currState = .transient
                
            default:
                break
            }
            
            handler?(currState)
            
        case .manualResignFirstResponder(let resignFirstResponder):
            resignFirstResponder(currTextField)
            currState = .transient
            
        default:
            break
        }
        
        
    }
    
    enum Event {
        case onLoad(Int)
        case shouldBeginEditing(UITextField)
        case shouldReturn
        case didEndEditing
        case manualResignFirstResponder((UITextField!) -> Void)
    }
    
    enum State: Int {
        
        case transient = -1
        case nameTag = 0
        case brandTag
        case countryTag
        case descriptionTag
        case unitCurrencyCodeTag
        case unitPriceTag
        case bundleCurrencyCodeTag
        
        init() {
            self = .transient
        }
        
    }
    
    
}
