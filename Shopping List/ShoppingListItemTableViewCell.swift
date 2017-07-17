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
    
    // MARK: - Model
    var shoppingListItem: ShoppingListItem? {
        didSet {
            
            listenForNotificationOfChangesToItem()
            
            //********* Cautionary: Put the following here causes an infinite loop ***************//
            //shoppingListItem?.managedObjectContext?.refresh(shoppingListItem!, mergeChanges: true)

            item = shoppingListItem?.item
            
            quantityToBuy.setTitle(String(describing: (shoppingListItem?.quantityToBuyConvert)!), for: .normal)
            
            if let selectedPriceRes = shoppingListItem?.selectedPrice, selectedPriceRes.count > 0 {
                let price = selectedPriceRes[0] as! Price
                selectedPrice.text = "$" + Helper.formatMoney(amount: price.valueConvert)
            }
            
            
//            if let stringPath = shoppingListItem?.item?.picture?.fileUrl {
//                itemPicture.image = UIImage(contentsOfFile: stringPath)
//                
//                //The following is an alternative to reading & displaying image file from web and filesystem.
//                //                let url = URL(fileURLWithPath: stringPath)
//                //                if let imageData = try? Data(contentsOf: url) {
//                //                    itemPicture.image = UIImage(data: imageData)
//                //                }
//            } else {
//                itemPicture.image = UIImage(named: "empty-photo")
//            }
        }
    }
    
    var item: Item? {
        didSet {
            itemName.text = item?.name
            brand.text = item?.brand
            
            if let stringPath = item?.picture?.fileUrl {
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
    
    var changesToItemObserver: NSObjectProtocol?
    
    deinit {
        if let observer = changesToItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension ShoppingListItemTableViewCell {
    
    func listenForNotificationOfChangesToItem() {
        let notificationCtr = NotificationCenter.default
        changesToItemObserver = notificationCtr.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                                            object: shoppingListItem?.item?.managedObjectContext, //Broadcaster
            queue: OperationQueue.main,
            using: { notification in
                
                let info = notification.userInfo
                let changedObjects = info?[NSUpdatedObjectsKey] as! NSSet
                
                for changedObject in changedObjects {
                    if let changedItem = changedObject as? Item {
                        self.item = changedItem
                    }
                }
        })
        
    }
    

}
