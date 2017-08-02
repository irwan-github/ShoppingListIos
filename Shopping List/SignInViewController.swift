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
    
    var isPendingRegistration: Bool = false
    
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
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlertWith(title: "Missing email", message: "Please provide email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlertWith(title: "Missing Password", message: "Please provide password")
            return
        }
        
        //onSimpleSignUp(email: email, password: password)
        onRegisterNewAccount(email: email, password: password)
    }
    
    private func onSimpleSignUp(email: String, password: String) {
        
        // Create the user with the provided credentials
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            guard let user = user, error == nil else {
                self.self.showAlertWith(title: "Registration error", message: error!.localizedDescription)
                return
            }
            
            self.initializeUser(user: user, password: password)
            self.performSegue(withIdentifier: "Post Authentication", sender: self)
        })
    }
    
    private func initializeUser(user: User, password: String) {
        
        self.ref.child("users").child(user.uid).setValue(["email": user.email])
        
        self.setUserDefaults(userEmail: (user.email)!, password: password)
    }
    
    private func onRegisterNewAccount(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
            
            (user, error) in
            
            if error != nil {
                self.showAlertWith(title: "Error", message: error!.localizedDescription)
            } else {
                user?.sendEmailVerification(completion: { error in
                    
                    if error != nil {
                        
                        self.showAlertWith(title: "Registration error", message: error!.localizedDescription)
                    } else {
                        self.isPendingRegistration = true
                        self.initializeUser(user: user!, password: password)
                        self.showAlertWith(title: "Registration success", message: "Please check email to confirm registration and resend the item", okHandler: {
                        
                            UIAlertAction in
                            
                            self.performSegue(withIdentifier: "Post Authentication", sender: self)
                        })
                        
                    }
                })
            }
        })
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        
        validateEmail()
        
        validatePassword()
        
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: password, completion: { (user, error ) in
            
            if error != nil {
                self.showAlertWith(title: "Sign in error", message: error!.localizedDescription)
            } else {
                
                self.setUserDefaults(userEmail: (user?.email)!, password: password)
                
                self.performSegue(withIdentifier: "Post Authentication", sender: self)
            }
        })
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapReset(_ sender: Any) {
        resetPassword()
    }
    
    private func resetPassword() {
        
        validateEmail()
        
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!, completion: { error in
            
            if error != nil {
                self.showAlertWith(title: "Error resetting password", message: error?.localizedDescription)
            } else{
                self.showAlertWith(title: "Password reset", message: "Check email to reset")
            }
            
        })
    }

    func showAlertWith(title: String, message: String?, okHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Persist user settings and make it available to iOS Settings
    */
    private func setUserDefaults(userEmail: String, password: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userEmail, forKey: "username")
        
        let password = self.passwordTextField.text
        userDefaults.set(password, forKey: "password")
        
        userDefaults.synchronize()
    }
    
    private func validateEmail() {
        if let email = emailTextField.text, email.isEmpty {
            showAlertWith(title: "Missing email", message: "Please provide email")
            return
        }
    }
    
    private func validatePassword() {
        if let password = passwordTextField.text, password.isEmpty {
            showAlertWith(title: "Missing password", message: "Please provide password")
            return
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
