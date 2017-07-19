//
//  ShoppingListSummaryTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 16/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit


/// Show the name and comment for a shopping list.
/// It displays icons for user for updating of metadata information of existing shopping list

class ShoppingListSummaryTableViewCell: UITableViewCell {
    
    var shoppingList: ShoppingList? {
        didSet {
            shoppingListNameLabel?.text = shoppingList?.name
            shoppingListCommentLabel?.text = shoppingList?.comments
        }
    }

    /**
     The button that will be used for the purpose of editing. It is up to the tableview controller to handle the ui logic,
     like when to hide or show it. In addition, the action handler for the button must also be provided by tableview controller in the form of a closure.
    */
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var shoppingListCommentLabel: UILabel!
    
    /**
        Action handler when user taps on update button for an existing shopping list
     */
    var onChangeShoppingListMetaDataHandler: ((ShoppingList) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /**
     On the update shopping list button tapped.
    */
    @IBAction func onChangeShoppingListMetaData(_ sender: UIButton) {

        onChangeShoppingListMetaDataHandler?(shoppingList!)
    }
}
