//
//  AccountViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 30/03/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    
    @IBOutlet weak var EditUserInfoButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var landlordInfoWarningLabel: UILabel!
    @IBOutlet weak var landlordNameLabel: UILabel!
    @IBOutlet weak var landlordPhoneLabel: UILabel!
    @IBOutlet weak var landlordEmailLabel: UILabel!
    
    let userRef = Auth.auth().currentUser?.uid
    let userEmail = Auth.auth().currentUser?.email
    let dbRef = Firestore.firestore()
    var editingMode = false
    let user = [String]()
    var firstName: String?
    var lastName: String?
    var phone: String?
    var docID: String?
    var landlordID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        
        if landlordID != nil {
            getLandlordInfo()
        }
    }
    
    func getUserInfo() {
        dbRef.collection("users").whereField("uid", isEqualTo: userRef!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
                self.firstNameTextField.text = "Error fetching user info"
            }
            else {
                for document in snapshot!.documents {
                    let data = document.data()
                    self.docID = document.documentID
                    self.firstName = data["first_name"] as? String
                    self.lastName = data["last_name"] as? String
                    self.phone = data["phone"] as? String
                    self.landlordID = data["landlordID"] as? String
                    self.firstNameTextField.text = self.firstName
                    self.lastNameTextField.text = self.lastName
                    self.emailTextField.text = self.userEmail
                    self.phoneNumberTextField.text = self.phone

                }
            }
        }
    }
    
    @IBAction func editUserInfo(_ sender: Any) {
                
        if editingMode == false{
            editingMode = true
            EditUserInfoButton.setTitle("Save", for: .normal)
            firstNameTextField.isUserInteractionEnabled = true
            lastNameTextField.isUserInteractionEnabled = true
            passwordTextField.isUserInteractionEnabled = true
            emailTextField.isUserInteractionEnabled = true
            phoneNumberTextField.isUserInteractionEnabled = true
        }
        else {
            editingMode = false
            EditUserInfoButton.setTitle("Edit", for: .normal)
            firstNameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            passwordTextField.isUserInteractionEnabled = false
            emailTextField.isUserInteractionEnabled = false
            phoneNumberTextField.isUserInteractionEnabled = false
            
            if firstNameTextField.text != firstName {
                let newFirstName = firstNameTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["first_name" : newFirstName!])
            }
            if lastNameTextField.text != lastName {
                let newLastName = lastNameTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["last_name" : newLastName!])
            }
            if emailTextField.text != userEmail {
                let newEmail = emailTextField.text
                Auth.auth().currentUser?.updateEmail(to: newEmail!, completion: { (error) in
                    if error != nil{
                        print(error!)
                    }
                })
            }
            if passwordTextField.text != "Password123!" {
                
                let newPassword = passwordTextField.text
                Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: { (error) in
                    if error != nil{
                        print(error!)
                    }
                })
            }
            if phoneNumberTextField.text != phone {
                let newPhoneNumber = phoneNumberTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["last_name" : newPhoneNumber!])
            }
        }
    }
    
    func getLandlordInfo() {
        
        dbRef.collection("users").whereField("uid", isEqualTo: landlordID!).getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            }
            else{
                for document in snapshot!.documents {
                    let data = document.data()
                    let landlordName = data["user_name"] as? String
                    let landlordPhone = data["phone"] as? String
                    
                    self.landlordNameLabel.text = landlordName
                    self.landlordPhoneLabel.text = landlordPhone
                    }
            }
        }
    }
    
    
    
}
