//
//  MoneyUITextFieldDelegate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 5/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class MoneyUITextFieldDelegate: NSObject, UITextFieldDelegate {

//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        var textStringTemp = textField.text ?? "0.00"
//        
//        if textStringTemp != "0.00" {
//            textStringTemp = stripLeadingZero(input: textStringTemp)
//        } else {
//            textStringTemp = ""
//        }
//        
//        let textString = textStringTemp as NSString
//        
//        let newRange = NSMakeRange(textStringTemp.characters.count, 0)
//        
//        var newString = textString.replacingCharacters(in: newRange, with: string)
//        
//        let intInput = Int(newString as String)
//        
//        let dollars = intInput!/100
//        
//        let cents = intInput! % 100
//        
//        let centsString = String(cents)
//        
//        let moneyString = String(dollars) + "." + (centsString.characters.count == 1 ? "0" + centsString : centsString)
//        
//        textField.text = moneyString
//        
//        return false
//    }
//    
//    func stripLeadingZero(input: String) -> String {
//        
//        let multiplier: Double = 100
//        
//        let val = (Double(input))!
//        
//        let intVal = Int(val * multiplier)
//        
//        return String(intVal)
//    }
    
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
        
        textField.text = moneyString
        
        return false
    }
    
}
