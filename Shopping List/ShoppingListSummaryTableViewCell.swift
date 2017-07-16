//
//  ShoppingListSummaryTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 16/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class ShoppingListSummaryTableViewCell: UITableViewCell {
    
    var shoppingList: ShoppingList? {
        didSet {
            shoppingListNameLabel?.text = shoppingList?.name
            shoppingListCommentLabel?.text = shoppingList?.comments
        }
    }

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var shoppingListCommentLabel: UILabel!
    
    var onChangeShoppingListMetaDataHandler: ((ShoppingList) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onChangeShoppingListMetaData(_ sender: UIButton) {
        onChangeShoppingListMetaDataHandler?(shoppingList!)
    }
}
