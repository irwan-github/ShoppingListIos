//
//  ItemDetailViewController.swift
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
            
            if itemImageView != nil {
                
                let placeHolderEmptyItem = UIImage(named: "item_placeholder")
                let image = PictureUtil.retrievePlaceHolderImage(placeHolderKey: PictureUtil.EMPTY_IMAGE_ITEM_DETAIL, placeHolderImage: placeHolderEmptyItem!, width: itemImageView.frame.width, height: itemImageView.frame.height)
                
                itemImageView?.image = image
            }
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
        
        //Prepare for a popover segue
        if segue.identifier == "More information" {
            
            let moreInformationVc = viewController as! ItemAdditionalDataViewController
            
            if let popoverPresentationController = moreInformationVc.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
            
            moreInformationVc.item = item
        }
    }
    
}

extension ItemDetailViewController: UIPopoverPresentationControllerDelegate {
    
    /**
     For iPad-sized class, the popover can be dismissed by tapping outside. However for iPhone, the view controller is displayed modally covering the presenting view controller. Thus, a button is needed to dismiss the modal view controller for iPhones.
     */
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        print("\(#function) - \(type(of: self))")
        
        guard let additionItemViewController = storyboard?.instantiateViewController(withIdentifier: "ItemAdditionalDataViewController") as? ItemAdditionalDataViewController else { return nil }
        
        additionItemViewController.item = item
        
        let navigationController = UINavigationController(rootViewController: additionItemViewController)
        
        additionItemViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: additionItemViewController, action: #selector(ItemAdditionalDataViewController.actionOnDoneAdditionalInfo))
        
        return navigationController
    }
    
    
}
