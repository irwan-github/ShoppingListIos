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
    
    var database = Database.database()
    var databaseRef = Database.database().reference()
    
    func send(shoppingListItem: ShoppingListItem, to recipientEmail: String, doAuthentication: @escaping () -> Void,
              completionOnSuccess: (() -> Void)?, completionOnFail: ((String) -> Void)?) {
        
        let sender = Auth.auth().currentUser
        
        if sender == nil {
            
            //Get user email from settings preference
            let userDefaults = UserDefaults.standard
            let username = userDefaults.value(forKey: "username") as? String
            let password = userDefaults.value(forKey: "password") as? String
            
            if let username = username, let password = password, !username.isEmpty, !password.isEmpty {
                
                Auth.auth().signIn(withEmail: username, password: password, completion: { (sender, error ) in
                    
                    if error != nil {
                        
                        completionOnFail?("Fail to sign in using \(sender?.email ?? "Unknown sender email").")
                        return
                        
                    } else {
                        
                        self.send(shoppingListItem, sender: sender!, userEmail: recipientEmail, completionOnSuccess: completionOnSuccess, completionOnFail: completionOnFail)
                    }
                })
                
            } else {
            
                doAuthentication()
                return
            }
        } else {
            
            send(shoppingListItem, sender: sender!, userEmail: recipientEmail, completionOnSuccess: completionOnSuccess, completionOnFail: completionOnFail)
        }
    }
    
    private func send(_ shoppingListItem: ShoppingListItem, sender: User, userEmail: String, completionOnSuccess: (() -> Void)?, completionOnFail: ((String) -> Void)?) {
        
        //Get the uid of receiver associated with the email
        let receiverRef = databaseRef.child("users")
        var receiverQuery = receiverRef.queryOrdered(byChild: "email")
        receiverQuery = receiverQuery.queryEqual(toValue: userEmail).queryLimited(toFirst: 1)
        
        receiverQuery.observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.children.allObjects.count == 0 {
                completionOnFail?("Recipient with email address \(userEmail) does NOT exist.")
            }
            
            let returns = snapshot.value as? [String: AnyObject] ?? [:]
            
            for (uidOfReceiver, value) in returns {
                print("Key is \(uidOfReceiver) - Value is \(value)")
            }
            
            guard let uidOfReceiver = returns.keys.first else { return }
            
            //Send to receiver
            var shoppingListDict = shoppingListItem.asDictionaryValues
            shoppingListDict["uidOfOriginator"] = sender.uid as AnyObject
            shoppingListDict["emailOfOriginator"] = sender.email as AnyObject
            
            let receiverDbRef = Database.database().reference()
            receiverDbRef.child("shopping_list_share_with/\(uidOfReceiver)").childByAutoId().setValue(shoppingListDict)
            
            completionOnSuccess?()
            
        }, withCancel: nil)
    }
    
    /**
     Authenticate using credentials from settings app if available
     */
    func authenticate() {
        //Get user email from settings preference
        let userDefaults = UserDefaults.standard
        let username = userDefaults.value(forKey: "username") as? String
        let password = userDefaults.value(forKey: "password") as? String
        
        if let username = username, let password = password, !username.isEmpty, !password.isEmpty {
            
            Auth.auth().signIn(withEmail: username, password: password, completion: { (user, error ) in
                
                if error != nil {
                    //self.performSegue(withIdentifier: "authenticate", sender: self)
                    
                }
            })
            
        }
    }
    
}
