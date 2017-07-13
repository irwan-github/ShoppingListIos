//
//  ShoppingListItemTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class ShoppingListItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemPicture: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var quantityToBuy: ToggleCircleButton!
    @IBOutlet weak var selectedPrice: UILabel!
    
    // MARK: - Model
    var shoppingListItem: ShoppingListItem? {
        didSet {
            //********* Put the following here causes an infinite loop ***************//
            //shoppingListItem?.managedObjectContext?.refresh(shoppingListItem!, mergeChanges: true)

            itemName.text = shoppingListItem?.item?.name
            brand.text = shoppingListItem?.item?.brand
            quantityToBuy.setTitle(String(describing: (shoppingListItem?.quantityToBuyConvert)!), for: .normal)
            
            if let selectedPriceRes = shoppingListItem?.selectedPrice {
                let price = selectedPriceRes[0] as! Price
                selectedPrice.text = "$" + Helper.formatMoney(amount: price.valueConvert)
            }
            
            
            if let stringPath = shoppingListItem?.item?.picture?.fileUrl {
                itemPicture.image = UIImage(contentsOfFile: stringPath)
                
                //The following is an alternative to reading & displaying image file from web and filesystem.
                //                let url = URL(fileURLWithPath: stringPath)
                //                if let imageData = try? Data(contentsOf: url) {
                //                    itemPicture.image = UIImage(data: imageData)
                //                }
            } else {
                itemPicture.image = UIImage(named: "empty-photo")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
