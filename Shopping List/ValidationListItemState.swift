
//  ValidationState.swift
//  Shopping List
//  Handle the state of a shopping list item
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

enum ValidationListItemState {
    
    case transient
    case existingListItem
    case newListItem
    
    enum Event {
        case onSaveListItem(OnSaveListItemEventHandler?)
        case onDeleteListItem((ValidationListItemState) -> Void)
        case onListItemExist
        case onListItemNew
        case onChangeCharacters
    }
    
    struct OnSaveListItemEventHandler {
        
        let validate: ((ValidationListItemState) -> Bool)?
        let actionIfValidateTrue: ((ValidationListItemState) -> Void)?
        
    }
    
    init() {
        self = .transient
    }
    
    mutating func handle(event: ValidationListItemState.Event, handleNextStateUiAttributes: ((ValidationListItemState) -> Void)?) {
        
        switch self {
            
        case .transient:
            
            switch event {
                
            case .onListItemExist:
                self = .existingListItem
                
            default:
                self = .newListItem
            }
            
        case .existingListItem:
            
            switch event {
                
            case .onSaveListItem(let eventHandler):
                
                if (eventHandler?.validate?(self))! {
                    
                    eventHandler?.actionIfValidateTrue?(self)
                    
                }
                
            case .onDeleteListItem(let deleteNote):
                deleteNote(self)
                
            default:
                break
                
            }
            
        case .newListItem:
            
            switch event {
                
            case .onSaveListItem(let eventHandler):
                
                if (eventHandler?.validate?(self))! {
                    
                    eventHandler?.actionIfValidateTrue?(self)
                    
                }
                
            default:
                break
            }
            
        }
        
        handleNextStateUiAttributes?(self)
        
    }
}
