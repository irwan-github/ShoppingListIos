//
//  FirebaseShare.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/8/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation
import Firebase

class FirebaseShare {
    
    var shoppingListItem: ShoppingListItem?
    var database = Database.database()
    var databaseRef = Database.database().reference()
    
    func send(shoppingListItem: ShoppingListItem, to userEmail: String, completionOnSuccess: (() -> Void)?, doAuthentication: () -> Void) {
        
        let sender = Auth.auth().currentUser
        
        if sender == nil {
            doAuthentication()
            return
        }
        
        //Get the uid of receiver associated with the email
        let usersRef = databaseRef.child("users")
        let usersBranch = usersRef.queryOrdered(byChild: "email")
        let userQuery = usersBranch.queryEqual(toValue: userEmail).queryLimited(toFirst: 1)
        
        userQuery.observeSingleEvent(of: .value, with: { snapshot in
        
            let returns = snapshot.value as? [String: AnyObject] ?? [:]
            
            for (uidOfReceiver, value) in returns {
                print("Key is \(uidOfReceiver) - Value is \(value)")
            }
            
            guard let uidOfReceiver = returns.keys.first else { return }

            //Send to receiver
            var shoppingListDict = shoppingListItem.asDictionaryValues
            shoppingListDict["uidOfOriginator"] = sender?.uid as AnyObject
            shoppingListDict["emailOfOriginator"] = sender?.email as AnyObject
            
            let receiverDbRef = Database.database().reference()
            receiverDbRef.child("shopping_list_share_with/\(uidOfReceiver)").childByAutoId().setValue(shoppingListDict)
            
            completionOnSuccess?()
            
        }, withCancel: nil)

    }
    
}
