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
    
    @IBOutlet weak var itemPicture: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var quantityToBuy: ToggleCircleButton!
    @IBOutlet weak var selectedPrice: UILabel!
    
    //Debug purpose
    var indexPath: IndexPath?
    
    // MARK: - Model
    var shoppingListItem: ShoppingListItem? {
        didSet {
            
            //********* Cautionary: Put the following here causes an infinite loop ***************//
            //shoppingListItem?.managedObjectContext?.refresh(shoppingListItem!, mergeChanges: true)
            
            item = shoppingListItem?.item
            
            quantityToBuy.setTitle(String(describing: (shoppingListItem?.quantityToBuyConvert)!), for: .normal)
            
            if let selectedPriceRes = shoppingListItem?.selectedPrice, selectedPriceRes.count > 0 {
                let price = selectedPriceRes[0] as! Price
                selectedPrice.text = "$" + Helper.formatMoney(amount: price.valueConvert)
            }
        }
    }
    
    var item: Item? {
        didSet {
            
            itemName.text = item?.name
            brand.text = item?.brand
            
            if let stringPath = item?.picture?.fileUrl {
                
                itemPicture.image = PictureUtil.materializePicture(from: stringPath)
                
                //The following is an alternative to reading & displaying image file from web and filesystem.
                //                let url = URL(fileURLWithPath: stringPath)
                //                if let imageData = try? Data(contentsOf: url) {
                //                    itemPicture.image = UIImage(data: imageData)
                //                }
            }
            
            if itemPicture.image == nil {
                itemPicture.image = UIImage(named: "empty-photo")
            }
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
