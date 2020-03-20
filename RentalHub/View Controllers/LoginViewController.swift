//
//  LoginViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 18/02/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()

    }
    

   func setUpElements() {
        errorLabel.alpha = 0
    }

    @IBAction func loginTapped(_ sender: Any) {
        //signing in the user
        signIn()
    }
    
    func signIn() {
        
        let email = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                //couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                self.transitionToHome()
            }
        }
    }
    
    
    func transitionToHome() {
        let tabBarController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as? UITabBarController
        
        view.window?.rootViewController = tabBarController
        view.window?.makeKeyAndVisible()
    }
}
