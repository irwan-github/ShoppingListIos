//
//  PictureUtil.swift
//  Shopping List
//
//  Created by Mirza Irwan on 17/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import UIKit

struct PictureUtil {
    
    static func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        //let scale = newWidth/image.size.width
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y:0, width: newWidth, height: newWidth))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     Specify locations manually by building a URL or string-based path from known directory names.
     This creates an absolute path to MY_APP/Documents directory
     */
    static var documentDirectory: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    static func pictureinDocumentFolder(filename: String) -> URL {
        
        return documentDirectory.appendingPathComponent(filename)
    }
    
    static func materializePicture(from filename: String) -> UIImage? {
        let url = pictureinDocumentFolder(filename: filename)
        let data = try? Data(contentsOf: url)
        if let data = data {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    private static var placeHolderImage: UIImage? = nil
    
    private static var placeHolderImages: [String: UIImage] = [String: UIImage]()
    
    /**
     Provides a cached placeholer image if available. The placeholder image is defined at build time.
     
     - Parameter placeHolderKey: Key.
     - Parameter placeHolderImage: Value.
     - Parameter width: Dimension to scale to.
     - Parameter height: Dimension to scale to.
     - Returns: A cached placeholder image if available
    */
    static func retrievePlaceHolderImage(placeHolderKey: String, placeHolderImage: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        
        if PictureUtil.placeHolderImages[placeHolderKey] != nil {
            return PictureUtil.placeHolderImages[placeHolderKey]
        }
        
        PictureUtil.placeHolderImages[placeHolderKey] = resizeImage(image: placeHolderImage, newWidth: width, newHeight: height)
        
        return PictureUtil.placeHolderImages[placeHolderKey]
    }
    
    static let EMPTY_IMAGE_ITEM_DETAIL: String = "EMPTY_IMAGE_ITEM_DETAIL"
    static let EMPTY_IMAGE_ITEM_MASTER_TABLE_CELL: String = " EMPTY_IMAGE_ITEM_MASTER_TABLE_CELL"

}
