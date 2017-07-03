//
//  ValidationState.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum ValidationState {
    
    case transient
    case existingItem
    case newItem
    indirect case warning(ValidationState)
    
    enum Event {
        case onSaveItem(OnSaveItemEventHandler?)
        case onDelete((ValidationState) -> Void)
        case onItemExist
        case onItemNew
        case onChangeCharacters
    }
    
    struct OnSaveItemEventHandler {
        
        let validate: ((ValidationState) -> Bool)?
        let actionIfValidateTrue: ((ValidationState) -> Void)?
        
    }
    
    init() {
        self = .transient
    }
    
    mutating func handle(event: ValidationState.Event, handleNextStateUiAttributes: ((ValidationState) -> Void)?) {
        
        switch self {
            
        case .transient:
            
            switch event {
                
            case .onItemExist:
                self = .existingItem
                
            default:
                self = .newItem
            }
            
        case .existingItem:
            
            switch event {
                
            case .onSaveItem(let eventHandler):
                
                if (eventHandler?.validate?(self))! {
                    
                    eventHandler?.actionIfValidateTrue?(self)
                    
                } else {
                    self = .warning(.existingItem)
                }
                
            case .onDelete(let deleteNote):
                deleteNote(self)
                
            default:
                break
                
            }
            
        case .newItem:
            
            switch event {
                
            case .onSaveItem(let eventHandler):
                
                if (eventHandler?.validate?(self))! {
                    
                    eventHandler?.actionIfValidateTrue?(self)
                    
                } else {
                    self = .warning(.newItem)
                }
                
            default:
                break
            }
            
        case .warning(let history):
            
            switch event {
                
            case .onChangeCharacters:
                
                self = history
                
            default:
                break
            }
            
        }
        
        handleNextStateUiAttributes?(self)
        
    }
}
