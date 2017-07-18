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
        case onFinishPickingCameraMedia(UIImage)
        case onDelete
        case onExist(ItemPicture?)
    }
    
    init() {
        self = .none
    }
    
    mutating func transition(event: PictureState.Event, handleNextStateUiAttributes: ((PictureState, ItemPicture?) -> Void)? = nil) {
        
        switch self {
            
        case .none:
            
            switch event {
                
            case .onExist(let itemPicture):
                self = .existing
                handleNextStateUiAttributes?(self, itemPicture)
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .new
                handleNextStateUiAttributes?(self, itemImageVc)
                
            default:
                break
            }
            
        case .new:
            switch event {
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .new
                handleNextStateUiAttributes?(self, itemImageVc)
                
            case .onSaveImage(let action):
                action(self)
                self = .existing
                handleNextStateUiAttributes?(self, nil)
                
            case .onDelete:
                self = .none
                handleNextStateUiAttributes?(self, nil)
                
            default:
                break
                
            }
            
        case .existing:
            switch event {
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .replacement
                handleNextStateUiAttributes?(self, itemImageVc)
                
            case .onDelete:
                self = .delete
                handleNextStateUiAttributes?(self, nil)
                
            default:
                break
            }
            
        case .replacement:
            switch event {
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .replacement
                handleNextStateUiAttributes?(self, itemImageVc)
                
            case .onSaveImage(let action):
                action(self)
                self = .existing
                handleNextStateUiAttributes?(self, nil)
                
            case .onDelete:
                self = .existing
                handleNextStateUiAttributes?(self, nil)
                
            default:
                break
                
            }
            
        case .delete:
            switch event {
                
            case .onSaveImage(let action):
                action(self)
                self = .existing
                handleNextStateUiAttributes?(self, nil)
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .replacement
                handleNextStateUiAttributes?(self, itemImageVc)
                
            default:
                break
                
            }
        }
        
    }
    
}
