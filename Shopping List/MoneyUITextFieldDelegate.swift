//
//  MoneyUITextFieldDelegate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 5/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class MoneyUITextFieldDelegate: NSObject, UITextFieldDelegate {
    var changeState: ChangeState?
    weak var vc: ShoppingListItemEditorViewController?
    var textFieldStateController: TextFieldStateController?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let decimalDigits = CharacterSet.decimalDigits
        
        let startWith = (textField.text)! as NSString
        
        let newString = startWith.replacingCharacters(in: range, with: string)
        
        if newString == "\n" {
            return false
        }
        
        var digits = ""
        
        for c in newString.unicodeScalars {
            
            if decimalDigits.contains(c) {
                digits.append(String(c))
            }
        }
        
        if digits.isEmpty {
            return false
        }
        
        let dollars = (Int(digits))! / 100
        let cents = (Int(digits))! % 100
        let centsString = String(cents)
        let moneyString = String(dollars) + "." + (centsString.characters.count == 1 ? "0" + centsString : centsString)
        
        if moneyString == "0.00" {
            textField.text = nil
        } else {
            textField.text = moneyString
        }
        
        changeState?.transition(event: .onChangeCharacters) {
            
            changeState in
            
            switch changeState {
                
            case .changed:
                self.vc?.doneButton.isEnabled = true
                
            default:
                break
            }
            
        }
        
        return false
    }
    
    //Just before a text object becomes first responder
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //Keep track of the current state but let iOS handle the keyboard and responder actions
        textFieldStateController?.next(event: .shouldBeginEditing(textField))
        
        return true
    }
    
    //When the user taps the return key, TextField sends message to the delegate to ask whether it should resign first responder.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textFieldStateController?.next(event: .shouldReturn)
        
        return true
    }
}
