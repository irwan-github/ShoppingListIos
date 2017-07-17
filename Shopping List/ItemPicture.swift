//
//  ItemPicture.swift
//  Shopping List
//
//  Created by Mirza Irwan on 17/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

class ItemPicture {
    
    var fullScaleImage: UIImage?
    var scaledDownImage: UIImage?

    
    init(fullScaleImage: UIImage? = nil) {
        self.fullScaleImage = fullScaleImage
    }
    
    func scale(widthToScale: CGFloat) {
        if fullScaleImage != nil {
            scaledDownImage = PictureUtil.resizeImage(image: fullScaleImage!, newWidth: widthToScale, newHeight: widthToScale)
        }
    }
}
