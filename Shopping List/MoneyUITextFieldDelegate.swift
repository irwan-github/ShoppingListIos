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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        changeState?.transition(event: .onChangeCharacters) {
            
            changeState in
            
            switch changeState {
                
            case .changed:
                self.vc?.doneButton.isEnabled = true
                
            default:
                break
            }
            
        }
        
        let startWith = (textField.text)! as NSString
        
        let newString = startWith.replacingCharacters(in: range, with: string)
        
        let decimalDigits = CharacterSet.decimalDigits
        
        var digits = ""
        
        for c in newString.unicodeScalars {
            
            if decimalDigits.contains(c) {
                digits.append(String(c))
            }
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
        
        return false
    }
    
}
