//
//  SignInViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/8/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    private var ref: DatabaseReference!
    
    var shoppingListItem: ShoppingListItem?
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            print("\(user?.email)")
            self.performSegue(withIdentifier: "signIn", sender: nil)
        }
        ref = Database.database().reference()
    }
    
    func showMessagePrompt(_ message: String) {
        print("Error -> \(message)")
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        print("\(#function) - \(type(of: self))")
        
        guard let email = emailTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        // Create the user with the provided credentials
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            guard let user = user, error == nil else {
                self.self.showAlertWith(title: "Registration error", message: error!.localizedDescription)
                return
            }
            
            self.ref.child("users").child(user.uid).setValue(["email": user.email])
            
        })
        
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error ) in
            
            if error != nil {
                self.showAlertWith(title: "Sign in error", message: error!.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "Share shopping list item", sender: self)
            }
        })
    }
    
    func showAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // Saves user profile information to user database
    //    func saveUserInfo(_ user: Firebase.User, withUsername username: String) {
    //
    //        // Create a change request
    //        //self.showSpinner {}
    //        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    //        changeRequest?.displayName = username
    //
    //        // Commit profile changes to server
    //        changeRequest?.commitChanges() { (error) in
    //
    //            //self.hideSpinner {}
    //
    //            if let error = error {
    //                self.showMessagePrompt(error.localizedDescription)
    //                return
    //            }
    //
    //            // [START basic_write]
    //            let branchUsers = self.ref.child("users")
    //            branchUsers.child(user.uid)
    //            // [END basic_write]
    //            self.performSegue(withIdentifier: "signIn", sender: nil)
    //        }
    //
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
