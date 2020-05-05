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
    
    @IBOutlet weak var tenantNameLabel: UILabel!
    @IBOutlet weak var tenantEmailLabel: UILabel!
    @IBOutlet weak var propertyAddressLabel: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var requestDateLabel: UILabel!
    @IBOutlet weak var acceptTenantButton: UIButton!
    
    var requestID: String?
    var tenantName: String?
    var address: String?
    var postcode: String?
    var date: String?
    var tenantEmail: String?
    var landlordEmail: String?
    var propertyID: String?
    var tenantID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tenantNameLabel.text = tenantName
        tenantEmailLabel.text = tenantEmail
        propertyAddressLabel.text = address
        postcodeLabel.text = postcode
        requestDateLabel.text = date
    }
    
    @IBAction func acceptTenantTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Accept new tenant", message: "Are you sure you want to add this tenant to the property they have requested?", preferredStyle: .alert)
        
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
                    //add a new region to the "tenants" array field for that property
                    propertyRef.document(documentID!).updateData([
                        "Tenants": FieldValue.arrayUnion([self.tenantID!])
                    ])
                    
                    //remove tenant from the property requests array
                    propertyRef.document(documentID!).updateData([
                        "Requests": FieldValue.arrayRemove([self.tenantID!])
                    ])
                    
                }
                let userRef = db.collection("users").document(self.tenantID ?? "")

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
