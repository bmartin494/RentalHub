//
//  UpdatePasswordViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 18/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class UpdatePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var backNavButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        
        let oldPassword = oldPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPassword = newPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmedPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if newPassword == confirmedPassword && newPassword != "" || confirmedPassword != "" {
                   
            Auth.auth().signIn(withEmail: (Auth.auth().currentUser?.email)!, password: oldPassword) { (result, error) in
                if error != nil {
                    //couldn't sign in
                    print(error!)
                    let alert = UIAlertController(title: "Uh oh!", message: error as? String, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                }
                else {
                    Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                        if error != nil{
                            print(error!)
                        }
                        else {
                            let alert = UIAlertController(title: "Success", message: "Your password has been updated.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                                self.performSegue(withIdentifier: "unwindToAccountView", sender: self)
                            }))
                            self.present(alert, animated: true)
                            
                        }
                    })
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Failed", message: "All fields are not filled out.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)

        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToAccountView", sender: self)
    }
}
