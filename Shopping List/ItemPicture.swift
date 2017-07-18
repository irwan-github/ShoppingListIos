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
    var filename: String?
    
    /**
     Item picture can originate from database with string-base filename OR it can originate from image picker with UIImage
    */
    init(filename: String? = nil, fullScaleImage: UIImage? = nil) {
        self.filename = filename
        
        if fullScaleImage != nil {
            self.fullScaleImage = fullScaleImage
        } else if let filename = self.filename {
            
            let absPath = PictureUtil.pictureinDocumentFolder(filename: filename)
            let imageData = try? Data(contentsOf: absPath)
            
            if let imageData = imageData {
                self.fullScaleImage = UIImage(data: imageData)
            }
        }
    }
    
    func scale(widthToScale: CGFloat) {
        if fullScaleImage != nil {
            scaledDownImage = PictureUtil.resizeImage(image: fullScaleImage!, newWidth: widthToScale, newHeight: widthToScale)
        }
    }
}
