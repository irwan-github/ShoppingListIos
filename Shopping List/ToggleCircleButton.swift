//
//  ToggleCircleButton.swift
//
//  Draws itself as a circular button. 
//  Background color is toggled according to states.
//  The title color is also toggled accoding to states.
//  The value of background color and title color is set in Attribute inspector of Interface Builder
//
//  Created by Mirza Irwan on 12/6/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleCircleButton: SwitchButton {
    
    @IBInspectable
    var scale: CGFloat = 1.0
    
    @IBInspectable
    var textOffColor: UIColor = UIColor.black
    
    @IBInspectable
    var textOnColor: UIColor = UIColor.black
    
    @IBInspectable
    var toggleOffColor: UIColor = UIColor.black
    
    @IBInspectable
    var toggleOnColor: UIColor = UIColor.green
    
    
    private var textColor: UIColor {
        get {
            switch buttonState {
            case .check:
                return textOnColor
            case .uncheck:
                return textOffColor
            }
        }
    }
    
    private var textBackgroundColor: UIColor {
        get {
            switch buttonState {
            case .check:
                return toggleOnColor
            case .uncheck:
                return toggleOffColor
            }
        }
    }
    
    private var theRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var theCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func pathForCircle() -> UIBezierPath {
        
        let path = UIBezierPath(arcCenter: theCenter, radius: theRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        
        path.lineWidth = 1.0
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        textBackgroundColor.set()
        
        setTitleColor(textColor, for: .normal)
        
        pathForCircle().stroke()
        
        pathForCircle().fill()
        
    }
    
    override func doToggle() {
        setNeedsDisplay()
    }
    
}
