//
//  CurrencyCodeTextFieldDelegate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 20/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class CurrencyCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    /**
     For view controller to help display the alert controller
     */
    var displayAlertAction: ((UIAlertController) -> Void)?
    
    var changeState: ChangeState? = nil
    
    var changeStateUiAttributesHandler: ((ChangeState) -> Void)? = nil
    
    let currencyHelper = CurrencyHelper()
    
    //Use this method to validate text as it is typed by the user. For example, you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("\(#function) \(type(of: self))")
        
//        print("Textfield value: \(textField.text ?? "empty")")
//        print("Range length: \(range.length) | Range Location: \(range.location)")
//        print("Replacement string: \(string)")
        
        //Must be only alphabet uppercase
        let alphabetSet = CharacterSet.uppercaseLetters
        
        guard let newUnicodeScalar = UnicodeScalar(string) else { return true }
        if !alphabetSet.contains(newUnicodeScalar) {
            return false
        }
        
        //Append the to-be string. Check valid currency code only when character count is three
        let presentString = textField.text!
        let toBeCurrencyCode = presentString + string
        if toBeCurrencyCode.characters.count == 3 {
            print("Check currency code now")
            print("\(CurrencyHelper.isValid(currencyCode: toBeCurrencyCode))")
            if !CurrencyHelper.isValid(currencyCode: toBeCurrencyCode) {
                showAlert(validationMessage: "\(toBeCurrencyCode) is an invalid currency code")
                return false
            }
            
        }
        
        //Must not go over 3 characters
        if toBeCurrencyCode.characters.count > 3 {
            return false
        }
        changeState?.transition(event: .onChangeCharacters, handleNextStateUiAttributes: changeStateUiAttributesHandler)
        return true
    }
    
    // The text field calls this method when it is asked to resign the first responder status. This can happen when the user selects another control or when you call the text field’s resignFirstResponder() method. Normally, you would return true from this method to allow the text field to resign the first responder status. You might return false however, in cases where your delegate detects invalid contents in the text field. Returning false prevents the user from switching to another control until the text field contains a valid value.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("\(#function) \(type(of: self))")
        
        //Check that it must be exactly 3-character
        let value = textField.text ?? ""
        
        let isThreeCharacters = value.characters.count == 3
        
        if !isThreeCharacters {
            showAlert(validationMessage: "Currency code must be 3 characters")
        }
        
        return isThreeCharacters
    }
    
    func showAlert(validationMessage: String) {
        let alertController = UIAlertController(title: "Validation", message: validationMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        displayAlertAction?(alertController)
    }
}
