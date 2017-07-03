//
//  ErrorUITextField.swift
//  CoolNotes Stanford
//
//  Created by Mirza Irwan on 26/6/17.
//  Copyright © 2017 Stanford. All rights reserved.
//

import UIKit

@IBDesignable class UITextErrorField: UIStackView {
    
    // MARK: model
    var errorText: String? {
        
        didSet {
            
            if let text = errorText, !text.isEmpty {
                animateError(text: text)
            } else {
                
                errorLabel.text = nil
                self.errorLabel.isHidden = true
            }
            
        }
        
    }
    
    var text: String? {
        
        get {
            return textField.text
        }
        
        set {
            textField.text = newValue
        }
    }
    
    private var errorLabel: UILabel = UILabel()
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    //Called by the Interface Builder/Storyboard at design time
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        setupTextField()
    }
    
    //Called by Interface Builder/Storyboard at runtime
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.axis = .vertical
        setupTextField()
    }
    
    private func setupTextField() {
        
        //Creates a zero-sized rectangle. The stackview will automatically define the button position.
        //This is fine if we are using AutoLayout
        let noteField = UITextField()
        
        //Disable the textfield's automatically generated constraints
        noteField.translatesAutoresizingMaskIntoConstraints = false
        
        //Need to add contraint to define textfield height
        //We let stack view adjust the width
        //noteField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        //The default initializer comes with no border. Let's give it a border
        noteField.borderStyle = .roundedRect
        
        //Disable the label's automatically generated constraints
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Need to add contraint to define label's height
        //We let stack view adjust the width
        //errorLabel.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        errorLabel.textColor = UIColor.red
        errorLabel.isHidden = true
        
        
        noteField.font = UIFont.preferredFont(forTextStyle: .body)
        
        addArrangedSubview(noteField)
        addArrangedSubview(errorLabel)
    }
    
    var textField: UITextField {
        return self.subviews[0] as! UITextField
    }
    
    var delegate: UITextFieldDelegate? {
        
        didSet {
            textField.delegate = delegate
        }
    }
    
    @IBInspectable var testing: String = ""
    
    @IBInspectable var errorTextColor: UIColor = UIColor.red {
        
        didSet {
            errorLabel.textColor = errorTextColor
        }
    }
    
    @IBInspectable var placeHolder: String? {
        
        didSet {
            textField.placeholder = placeHolder
        }
    }
    
    func animateErrorByFading(text: String?) {
        
        
        
        if errorText != nil {
            self.errorLabel.alpha = 0
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.addArrangedSubview(self.errorLabel)
                            
                            self.errorLabel.text = text
                            self.errorLabel.alpha = 1 },
                           completion: nil)
        }
        
        if errorLabel.alpha == 1, errorText == nil {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.errorLabel.alpha = 0 },
                           completion: { isCompleted in
                            self.errorLabel.text = text
                            self.removeArrangedSubview(self.errorLabel)
            })
        }
    }
    
    func animateError2(text: String?) {
        
        if text != nil {
            self.errorLabel.isHidden = true
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.errorLabel.text = text
                            self.errorLabel.isHidden = false },
                           completion: nil)
        }
        
        if text == nil || (text?.isEmpty)! {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.errorLabel.isHidden = true },
                           completion: { isCompleted in
                            self.errorLabel.text = text
            })
        }
    }
    
    func animateError3(text: String?) {
        
        if text != nil {
            self.errorLabel.isHidden = true
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.errorLabel.text = text
                            self.errorLabel.isHidden = false },
                           completion: nil)
        }
        
        if text == nil || (text?.isEmpty)! {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            self.errorLabel.isHidden = true },
                           completion: { isCompleted in
                            self.errorLabel.text = text
            })
        }
    }
    
    func animateError(text: String?) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        
                        self.errorLabel.text = text
                        
                        self.errorLabel.isHidden = (text == nil)
        },
                       completion: nil)
        
    }
    
    var isEnabled: Bool = true {
        didSet {
            textField.isEnabled = isEnabled
        }
    }
    
}
