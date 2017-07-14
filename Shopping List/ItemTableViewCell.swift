//
//  ItemTableViewCell.swift
//  Shopping List
//
//  Created by Mirza Irwan on 14/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    // MARK :- API
    var item: Item? {
        didSet {
            updateUi()
        }
    }
    
    func updateUi() {
        itemNameLabel.text = item?.name
        brandLabel.text = item?.brand
        itemDescriptionLabel.text = item?.itemDescription
    }


}
