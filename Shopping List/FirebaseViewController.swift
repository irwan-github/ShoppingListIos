//
//  FirebaseViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/8/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import Firebase

class FirebaseViewController: UIViewController {

    var shoppingListItem: ShoppingListItem?
    
    @IBOutlet weak var recipientEmailTextField: UITextField!
    
    @IBOutlet weak var firebaseMessage: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendButton.isEnabled = true
    }

    @IBAction func didTapSend(_ sender: UIButton) {
        sendButton.isEnabled = false
        share()
    }
    
    func share() {
        
        guard let recipientEmail = recipientEmailTextField.text else { return }
        
        let share = FirebaseShare()
        share.send(shoppingListItem: shoppingListItem!, to: recipientEmail, completionOnSuccess: {
            self.firebaseMessage.text = "Success"
            self.sendButton.isEnabled = true
            
        }, doAuthentication: {
            
            //Get user email from settings preference
            let userDefaults = UserDefaults.standard
            let username = userDefaults.value(forKey: "username") as? String
            let password = userDefaults.value(forKey: "password") as? String
            
            if let username = username, let password = password, !username.isEmpty, !password.isEmpty {
                
                Auth.auth().signIn(withEmail: username, password: password, completion: { (user, error ) in
                    
                    if error != nil {
                        self.performSegue(withIdentifier: "authenticate", sender: self)
                    }
                })
                
            } else {
                self.performSegue(withIdentifier: "authenticate", sender: self)
            }
        })
    }
    
    @IBAction func unwindFromFirebaseAuthentication(_ source: UIStoryboardSegue) {
        share()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
