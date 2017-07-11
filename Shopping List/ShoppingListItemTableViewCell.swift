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
    
    // MARK: - Model
    var shoppingListItem: ShoppingListItem? {
        didSet {
            itemName.text = shoppingListItem?.item?.name
            brand.text = shoppingListItem?.item?.brand
            quantityToBuy.setTitle(String(describing: (shoppingListItem?.quantity)!), for: .normal)
            if let stringPath = shoppingListItem?.item?.picture?.fileUrl {
                itemPicture.image = UIImage(contentsOfFile: stringPath)
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
