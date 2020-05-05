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
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var landlordTenantSelector: UISegmentedControl!
    
    
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
            if self.firstNameTxt.text == nil || self.lastNameTxt.text == nil || self.emailTxt.text == nil || self.passwordTxt.text == nil || self.phoneNumberTxt.text == nil {
                
                let alert = UIAlertController(title: "Fields incomplete", message: "Please fill out all fields in order to sign up.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
            else{
                //create cleaned versions of the data
                let firstName = self.firstNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let lastName = self.lastNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let email = self.emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = self.passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let phone = self.phoneNumberTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let accountType = self.landlordTenantSelector.selectedSegmentIndex
                
                if accountType == 0 {
                    let alert = UIAlertController(title: "Account type check", message: "You have chosen to create a 'tenant' user account?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                        //create the user
                        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                            //check for errors
                            if err != nil {
                                self.showError("Error creating user")
                            }
                            else {
                                
                                //user created successfully, storing first and last name
                                let db = Firestore.firestore()
                                
                                db.collection("users").addDocument(data: ["First_Name":firstName, "Last_Name":lastName, "Account_Type":accountType, "Phone":phone,"uid": result!.user.uid, "LinkRequest_Sent": false, "Email":email]) { (error) in
                                    
                                    if error != nil {
                                        self.showError("User data could not be saved")
                                    }
                                }
                                
                                //self.sendVerificationMail()
                                //transition to home screen
                                self.transitionToLogin()
                            }
                        }
                    }))
                    self.present(alert, animated: true)
                }
                if accountType == 1 {
                    let alert = UIAlertController(title: "Account type check", message: "You have chosen to create a 'landlord' user account?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                        //create the user
                        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                            //check for errors
                            if err != nil {
                                self.showError("Error creating user")
                            }
                            else {
                                
                                //user created successfully, storing first and last name
                                let db = Firestore.firestore()
                                
                                db.collection("users").addDocument(data: ["First_Name":firstName, "Last_Name":lastName, "Account_Type":accountType, "Phone":phone, "uid": result!.user.uid, "Email":email]) { (error) in
                                    
                                    if error != nil {
                                        self.showError("User data could not be saved")
                                    }
                                }
                                
                                //self.sendVerificationMail()
                                //transition to home screen
                                self.transitionToLogin()
                            }
                        }
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }

    public func sendVerificationMail() {
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
            })
        }
        else {
            // Either the user is not available, or the user is already verified.
        }
    }
    
    //error message display
    func showError(_ message : String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToLogin() {
        let landingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.landingController)
        
        view.window?.rootViewController = landingViewController
        view.window?.makeKeyAndVisible()
    }
}
