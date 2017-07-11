//
//  PictureState.swift
//  Shopping List
//
//  Created by Mirza Irwan on 27/6/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

enum PictureState {
    
    case none
    case existing
    case new
    case replacement
    case delete
    
    //Events
    enum Event {
        case onSaveImage((PictureState) -> Void)
        case onFinishPickingCameraMedia
        case onDelete
        case onExist
    }
    
    init() {
        self = .none
    }
    
    mutating func transition(event: PictureState.Event, handleNextStateUiAttributes: ((PictureState) -> Void)? = nil) {
        
        switch self {
            
        case .none:
            
            switch event {
                
            case .onExist:
                self = .existing
                
            case .onFinishPickingCameraMedia:
                self = .new
                
            default:
                break
            }
            
        case .existing:
            switch event {
                
            case .onFinishPickingCameraMedia:
                self = .replacement
                
            case .onDelete:
                self = .delete
                
            default:
                break
            }
            
        case .replacement:
            switch event {
                
            case .onSaveImage(let action):
                
                action(self)
                self = .existing
                
            default:
                break
                
            }
            
        case .new, .delete:
            switch event {
                
            case .onSaveImage(let action):
                action(self)
                self = .existing
                
            default:
                break
                
            }

        }
        
        
        handleNextStateUiAttributes?(self)
    }
    
}
