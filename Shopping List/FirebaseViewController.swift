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
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = calculatePreferredSize()
        
        if navigationController?.popoverPresentationController?.arrowDirection != UIPopoverArrowDirection.unknown {
            navigationItem.leftBarButtonItem = nil
        }
        
    }
    
    private func calculatePreferredSize() -> CGSize{
        let y = firebaseMessage.frame.origin.y
        let height = firebaseMessage.frame.size.height
        return CGSize(width: 0, height: y + height)
    }

    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        self.firebaseMessage.text = nil
        share()
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func share() {
        
        guard let recipientEmail = recipientEmailTextField.text else { return }
        
        let share = FirebaseShare()
        share.send(shoppingListItem: shoppingListItem!, to: recipientEmail, doAuthentication: {
            
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
        }, completionOnSuccess: {
            self.firebaseMessage.text = "Sent to \(recipientEmail)"
            self.firebaseMessage.textColor = UIColor.green
            self.firebaseMessage.textAlignment = .center
            self.sendButton.isEnabled = true
            
        }, completionOnFail: { errorMessage in
           
            self.firebaseMessage.text = errorMessage
            self.firebaseMessage.textColor = UIColor.red
            self.firebaseMessage.textAlignment = .natural
            self.sendButton.isEnabled = true
        })
    }
    
    @IBAction func unwindToFirebaseViewController(for segue: UIStoryboardSegue, sender: Any?) {
        
        let source = segue.source
        
        if segue.identifier == "Post Authentication" {
            
            let signInViewController = source as! SignInViewController
            
            //check pending account confirmation
            if signInViewController.isPendingRegistration {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                share()
            }
        }
        
        
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
