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
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(user?.email, forKey: "username")
                
                let password = self.passwordTextField.text
                userDefaults.set(password, forKey: "password")
                
                userDefaults.synchronize()
                
                self.performSegue(withIdentifier: "Share shopping list item", sender: self)
            }
        })
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
