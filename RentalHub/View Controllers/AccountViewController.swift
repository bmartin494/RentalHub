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
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var landlordInfoTitleLabel: UILabel!
    @IBOutlet weak var landlordNameTitleLabel: UILabel!
    @IBOutlet weak var landlordPhoneTitleLabel: UILabel!
    @IBOutlet weak var landlordInfoLabel: UILabel!
    @IBOutlet weak var landlordEmailTitleLabel: UILabel!
    
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
    var accountType: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        
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
                    self.firstName = data["First_Name"] as? String
                    self.lastName = data["Last_Name"] as? String
                    self.phone = data["Phone"] as? String
                    self.landlordID = data["LandlordID"] as? String
                    self.accountType = data["Account_Type"] as? Int
                    self.firstNameTextField.text = self.firstName
                    self.lastNameTextField.text = self.lastName
                    self.emailTextField.text = self.userEmail
                    self.phoneNumberTextField.text = self.phone
                    
                }
            }
            if self.accountType == 0 {
                self.landlordNameLabel.isHidden = false
                self.landlordEmailLabel.isHidden = false
                self.landlordPhoneLabel.isHidden = false
                self.landlordInfoTitleLabel.isHidden = false
                self.landlordNameTitleLabel.isHidden = false
                self.landlordPhoneTitleLabel.isHidden = false
                self.landlordInfoLabel.isHidden = false
                self.landlordEmailTitleLabel.isHidden = false
            }
            
            if self.landlordID != nil {
                self.getLandlordInfo()
            }
        }
    }
    
    @IBAction func editUserInfo(_ sender: Any) {
        
        if editingMode == false{
            
            editingMode = true
            EditUserInfoButton.setTitle("Save", for: .normal)
            firstNameTextField.isUserInteractionEnabled = true
            lastNameTextField.isUserInteractionEnabled = true
            emailTextField.isUserInteractionEnabled = true
            phoneNumberTextField.isUserInteractionEnabled = true
            
        }
        else {
            editingMode = false
            EditUserInfoButton.setTitle("Edit", for: .normal)
            firstNameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            emailTextField.isUserInteractionEnabled = false
            phoneNumberTextField.isUserInteractionEnabled = false
            
            if firstNameTextField.text != firstName {
                let newFirstName = firstNameTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["First_Name" : newFirstName!])
            }
            if lastNameTextField.text != lastName {
                let newLastName = lastNameTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["Last_Name" : newLastName!])
            }
            if emailTextField.text != userEmail {
                let newEmail = emailTextField.text
                Auth.auth().currentUser?.updateEmail(to: newEmail!, completion: { (error) in
                    if error != nil{
                        print(error!)
                    }
                })
            }
            if phoneNumberTextField.text != phone {
                let newPhoneNumber = phoneNumberTextField.text
                dbRef.collection("users").document(docID ?? "").updateData(["Last_Name" : newPhoneNumber!])
            }
        }
    }
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        performSegue(withIdentifier: "changePasswordSegue", sender: self)
    }
    
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.transitionToLogin()
        }))
        self.present(alert, animated: true)
    }
    
    func transitionToLogin() {
        
        let landingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.landingController)
        view.window?.rootViewController = landingViewController
        view.window?.makeKeyAndVisible()
    }
    
    func getLandlordInfo() {
        
        if landlordID != nil{
            landlordInfoLabel.isHidden = true
            dbRef.collection("users").whereField("uid", isEqualTo: landlordID!).getDocuments { (snapshot, error) in
                if error != nil {
                    print(error!)
                }
                else{
                    for document in snapshot!.documents {
                        let data = document.data()
                        let firstname = data["First_Name"] as? String
                        let lastname = data["Last_Name"] as? String
                        let landlordName = firstname! + " " + lastname!
                        let landlordEmail = data["Email"] as? String
                        let landlordPhone = data["Phone"] as? String
                        
                        self.landlordNameLabel.text = landlordName
                        self.landlordEmailLabel.text = landlordEmail
                        self.landlordPhoneLabel.text = landlordPhone
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToAccountView(_ unwindSegue: UIStoryboardSegue) {}
    
}
