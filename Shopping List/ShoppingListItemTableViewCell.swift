//
//  ShoppingListItemTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListItemTableViewCell: UITableViewCell {
    
    // MARK: - API and Model
    var shoppingListItem: ShoppingListItem? {
        didSet {
            
            //********* Cautionary: Put the following here causes an infinite loop ***************//
            //shoppingListItem?.managedObjectContext?.refresh(shoppingListItem!, mergeChanges: true)
            
            item = shoppingListItem?.item
            
            quantityToBuy.setTitle(String(describing: (shoppingListItem?.quantityToBuyConvert)!), for: .normal)

            if let selectedPriceRes = shoppingListItem?.selectedPrice, selectedPriceRes.count > 0 {
                let price = selectedPriceRes[0] as! Price
                selectedPriceLabel.text = price.currencySymbol! + " " + Helper.formatMoney(amount: price.valueConvert)
            }
        }
    }
    
    var item: Item? {
        didSet {
            
            itemNameLabel.text = item?.name
            brandLabel.text = item?.brand
            
            if let stringPath = item?.picture?.fileUrl {
                
                itemPictureImageView.image = PictureUtil.materializePicture(from: stringPath)

                //The following is an alternative to reading & displaying image file from web and filesystem.
                //                let url = URL(fileURLWithPath: stringPath)
                //                if let imageData = try? Data(contentsOf: url) {
                //                    itemPicture.image = UIImage(data: imageData)
                //                }
            } else {
                
                itemPictureImageView.image = PictureUtil.retrievePlaceHolderImage(placeHolderKey: PictureUtil.EMPTY_IMAGE_ITEM_MASTER_TABLE_CELL, placeHolderImage: UIImage(named: "ic_photo")!, width: itemPictureImageView.bounds.width, height: itemPictureImageView.bounds.width)
            }
            
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var itemPictureImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var quantityToBuy: ToggleCircleButton!
    @IBOutlet weak var selectedPriceLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
