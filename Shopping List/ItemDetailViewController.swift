//
//  ItemBaseViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 14/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {
    
    // MARK: - API and Model
    
    var shoppingListItem: ShoppingListItem? {
        didSet {
            item = shoppingListItem?.item
        }
    }
    
    var item: Item? {
        didSet {
            updateUi()
        }
    }
    
    var persistentContainer: NSPersistentContainer? = AppDelegate.persistentContainer
    
    // MARK: - Properties
    
    // MARK: - UIViewController's version of model
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        listenForNotificationOfChangesToItem()
        updateUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(#function) - \(type(of: self))")
    }
    
    var changesToItemObserver: NSObjectProtocol?
    
    /**
     Listen for changes saved in Shopping list editor view controller. Without this, any changes made in Shopping list editor view controller to pictures will not be known to this view controller
     */
    private func listenForNotificationOfChangesToItem() {
        let notificationCtr = NotificationCenter.default
        changesToItemObserver = notificationCtr.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: item?.managedObjectContext, //Broadcaster
            queue: OperationQueue.main,
            using: { notification in
                
                let info = notification.userInfo
                if let changedObjects = info?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                    for changedObject in changedObjects {
                        print("\(changedObject)")
                        if let changedItem = changedObject as? Item, changedItem == self.item {
                            self.item = changedItem
                        }
                    }
                    
                }
        })
        
    }
    
    deinit {
        if let observer = changesToItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func updateUi() {
        
        title = item?.name
        
        if let stringPath = item?.picture?.fileUrl {
            itemImageView?.image = PictureUtil.materializePicture(from: stringPath)
            
            //The following is an alternative to reading & displaying image file from web and filesystem.
            //                let url = URL(fileURLWithPath: stringPath)
            //                if let imageData = try? Data(contentsOf: url) {
            //                    itemPicture.image = UIImage(data: imageData)
            //                }
        } else {
            itemImageView?.image = nil
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var viewController = segue.destination
        
        if let viewControllerAsNavigationController = viewController as? UINavigationController {
            viewController = viewControllerAsNavigationController.visibleViewController!
        }
        
        if segue.identifier == "Shopping List Item Editor" {
            let shoppingListEditorVc = viewController as! ShoppingListItemEditorViewController
            shoppingListEditorVc.shoppingListItem = shoppingListItem
        }
        
        if segue.identifier == "More information" {
            let moreInformationVc = viewController as! ItemAdditionalDataViewController
            moreInformationVc.item = item
        }
    }
    
    @IBAction func showMoreItemInformation(_ sender: UIButton) {
        
    }
    
}
