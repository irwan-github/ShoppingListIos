//
//  SwitchButton.swift
//  
//  A button that toggles between two states.
//  Subclass will query the button state to customize the look and behaviour
//
//  Created by Mirza Irwan on 12/6/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

@IBDesignable
class SwitchButton: UIButton {
    
    @IBInspectable
    var isOn: Bool {
        
        get {
            switch buttonState {
            case .check:
                return true
            case .uncheck:
                return false
            }
        }
        
        set {
            if newValue {
                buttonState = .check
            } else {
                buttonState = .uncheck
            }
        }
    
    }
    
    internal var buttonState: State = .uncheck {
        didSet {
            print("buttonState didSet")
            doToggle()
        }
    }
    
    enum State {
        
        case check
        case uncheck
        
        init() {
            self = .uncheck
        }
        
        mutating func transition() {
            
            switch self {
            case .check:
                self = .uncheck
            case .uncheck:
                self = .check
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    internal func setupButton() {
                
        addTarget(self, action: #selector(onButtonClicked(_:)), for: .touchUpInside)
        
    }
    
    internal func onButtonClicked(_ sender: UIButton) {
        
        buttonState.transition()
    }
    
    func doToggle() {

    }

}
