//
//  ChangeState.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum ChangeState {
    
    case unchanged
    case changed
    case alert
    
    enum Event {
        case onStart
        case onChangeCharacters
        case onCameraCapture
        case onCancel((ChangeState) -> Void)
        case onStay
        case onLeave
        case onSelectPrice
    }
    
    init() {
        self = .unchanged
    }
    
    mutating func transition(event: Event, handleNextStateUiAttributes: ((ChangeState) -> Void)? = nil ) {
        
        switch self {
            
        case .unchanged:
            
            switch event {
                
            case .onChangeCharacters, .onCameraCapture, .onSelectPrice:
                self = .changed
                
            case .onCancel(let cancel):
                cancel(self)
                
            default:
                break
            }
            
        case .changed:
            
            switch event {
                
            case .onCancel(let cancel):
                cancel(self)
                self = .alert
                
            default:
                break
            }
            
        case .alert:
            switch event {
                
            case .onStay:
                self = .changed
                
            default:
                break
            }
            
        }
        
        handleNextStateUiAttributes?(self)
        
    }
    
}
