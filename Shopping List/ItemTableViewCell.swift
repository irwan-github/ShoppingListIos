//
//  ItemTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 14/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    // MARK :- API
    var item: Item? {
        didSet {
            updateUi()
        }
    }
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    @IBOutlet weak var itemPicture: UIImageView!
    
    func updateUi() {
        itemNameLabel.text = item?.name
        brandLabel.text = item?.brand
        itemDescriptionLabel.text = item?.itemDescription
        
        if let filename = item?.picture?.fileUrl {
            itemPicture.image = PictureUtil.materializePicture(from: filename)
        } else {
            let emptyPicturePlaceHolder = PictureUtil.retrievePlaceHolderImage(placeHolderKey: PictureUtil.EMPTY_IMAGE_ITEM_MASTER_TABLE_CELL, placeHolderImage: UIImage(named: "ic_photo")!,
                width: itemPicture.frame.width, height: itemPicture.frame.width)
            
            itemPicture.image = emptyPicturePlaceHolder
        }
    }
    
    
}
