//
//  TextFieldStateController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 7/8/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

class TextFieldStateController {
    
    var currTextField: UITextField!
    
    var currState = State()
    
    var nextResponder: ((State, UITextField) -> Void)?
    
    func next(event: Event) {
        
        switch event {
            
        case .onLoad(let textField):
            
            guard let stateInd = State(rawValue: textField.tag) else { break }
            currTextField = textField
            
            switch currState {
                
            case .transient:
                currState = stateInd
                
            default:
                break
                
            }
            
            nextResponder?(currState, currTextField)
            
        //At this point, iOS will display the keyboard
        case .shouldBeginEditing(let textField):
            
            currState = State(rawValue: textField.tag)!
            currTextField = textField
            
        //Define the next textfield that will receive focus. This event is called before shouldBeginEditing event
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
                currState = .bundlePriceTag
                
            case .bundlePriceTag:
                currState = .transient
                
            default:
                break
            }
            
            nextResponder?(currState, currTextField)
            
        case .onManualResignFirstResponder():
            resignFirstResponder()
            currState = .transient
            
        default:
            break
        }
    }
    
    private func resignFirstResponder() {
        currTextField?.resignFirstResponder()
    }
    
    enum Event {
        case onLoad(UITextField) //Use this event for viewDidLoad event
        case shouldBeginEditing(UITextField)
        case shouldReturn
        case didEndEditing
        case onManualResignFirstResponder
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
        case bundlePriceTag
        
        init() {
            self = .transient
        }
        
    }
    
    
}
