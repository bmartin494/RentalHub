//
//  CreatePropertyViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 17/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class CreatePropertyViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countyTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var createPropertyButton: UIButton!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var rentTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func createPropertyTapped(_ sender: Any) {
        
        let error = validateFields()
        if error != nil {
            //something wrong with field inputs, show error message
            let alert = UIAlertController(title: "Fields incomplete", message: "Please fill out all fields in order to sign up.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            
            //create cleaned versions of the data
            let address = self.addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let city = self.cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let county = self.countyTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let postcode = self.postcodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let rent = self.rentTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let dueDate = self.dueDateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            
            //user created successfully, storing first and last name
            let db = Firestore.firestore()
            
            db.collection("properties").addDocument( data: ["Address":address, "City":city, "County":county, "Postcode":postcode, "LandlordID":Auth.auth().currentUser!.uid,"Rent":rent, "Due_Date":dueDate,"Tenants":[]]) { (error) in
                
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "Could not create new property", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Property created", message: "You can now view this property in the portfolio section", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)

                    self.addressTextField.text = nil
                    self.cityTextField.text = nil
                    self.countyTextField.text = nil
                    self.postcodeTextField.text = nil
                }
            }
        }
    }
    
    //checks input fields, if valid returns nil, if not returns error message
    func validateFields() -> String? {
        //check all fields filled
        if addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            countyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            postcodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || dueDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || rentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Fields incomplete"
        }
        
        return nil
    }
    
}
