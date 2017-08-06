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
    
    case transient
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
        case onLoad(String?) //filename of picture file
    }
    
    init() {
        self = .transient
    }
    
    mutating func transition(event: PictureState.Event, handleNextStateUiAttributes: ((PictureState, ItemPicture?) -> Void)? = nil) {
        
        switch self {
            
        case .transient:
            switch event {
                
            case .onLoad(let pictureFilename):
                
                var itemImageVc: ItemPicture? = nil
                
                if pictureFilename == nil {
                    
                    let placeholderImage = UIImage(named: "ic_add_a_photo")!
                    itemImageVc = ItemPicture(fullScaleImage: placeholderImage)
                    self = .none
                } else {
                    
                    let originalUiImage = PictureUtil.materializePicture(from: pictureFilename!)
                    itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                    self = .existing
                }
                
                handleNextStateUiAttributes?(self, itemImageVc)
                
            case .onFinishPickingCameraMedia(let originalUiImage):
                let itemImageVc = ItemPicture(fullScaleImage: originalUiImage)
                self = .new
                handleNextStateUiAttributes?(self, itemImageVc)
                
            default:
                break
            }
            
            
        case .none:
            
            switch event {
                                
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
