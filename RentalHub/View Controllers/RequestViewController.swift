//
//  RequestViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 30/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class RequestViewController: UIViewController {
    
    @IBOutlet weak var tennantNameLabel: UILabel!
    @IBOutlet weak var tennantEmailLabel: UILabel!
    @IBOutlet weak var propertyAddressLabel: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var requestDateLabel: UILabel!
    @IBOutlet weak var acceptTennantButton: UIButton!
    
    var requestID: String?
    var tenantName: String?
    var address: String?
    var postcode: String?
    var date: String?
    var tenantEmail: String?
    var landlordEmail: String?
    var propertyID: String?
    var tennantID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tennantNameLabel.text = tenantName
        tennantEmailLabel.text = tenantEmail
        propertyAddressLabel.text = address
        postcodeLabel.text = postcode
        requestDateLabel.text = date
    }
    
    @IBAction func acceptTennantTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Accept new tennant", message: "Are you sure you want to add this tennant to the property they have requested?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            
            var documentID: String?
            let db = Firestore.firestore()
            let propertyRef = db.collection("properties")
            
            propertyRef.whereField("PropertyID", isEqualTo: self.propertyID!).getDocuments { (snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else {
                    if snapshot!.count > 0 {
                        for document in snapshot!.documents {
                            documentID = document.documentID
                        }
                    }
                    //add a new region to the "Tennants" array field for that property
                    propertyRef.document(documentID!).updateData([
                        "Tennants": FieldValue.arrayUnion([self.tennantID!])
                    ])
                    
                    //remove tennant from the property requests array
                    propertyRef.document(documentID!).updateData([
                        "Requests": FieldValue.arrayRemove([self.tennantID!])
                    ])
                    
                }
                let userRef = db.collection("users").document(self.tennantID ?? "")

                // Add the "Assigned_Property" field to the user document
                userRef.updateData([
                    "Assigned_Property": self.propertyID!
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
                //add the "LandlordID" field to the user document
                userRef.updateData([
                    "LandlordID": Auth.auth().currentUser!.uid
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }

                
                db.collection("requests").document(self.requestID!).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                self.performSegue(withIdentifier: "unwindToPropertyView", sender: self)
            }}))
        present(alert, animated: true)
        
    }
    
}
