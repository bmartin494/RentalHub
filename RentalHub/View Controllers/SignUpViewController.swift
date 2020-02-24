//
//  SignUpViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 18/02/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    
    func setUpElements() {
        errorLabel.alpha = 0
    }
    
    
    //checks input fieldds, if valid returns nil, if not returns error message
    func validateFields() -> String? {
        //check all fields filled
        if firstNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        //check is password is secure
        let cleanedPassword = passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //validate the fields
        let error = validateFields()
        
        if error != nil {
            //something wrong with field inputs, show error message
            showError(error!)
        }
        else {
            //create cleaned versions of the data
            let firstName = self.firstNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = self.lastNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = self.emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self.passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            //check for errors
            if err != nil {
                self.showError("Error creating user")
            }
            else {
                
                //user created successfully, storing first and last name
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["first_name":firstName, "last_name":lastName, "uid": result!.user.uid]) { (error) in
                    
                    if error != nil {
                        self.showError("User data could not be saved")
                    }
                }
             //transition to home screen
                self.transitionToHome()
            }
            }
        }
    }
    
    //error message display
    func showError(_ message : String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
