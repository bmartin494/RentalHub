//
//  FullDocumentViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 06/05/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

class FullDocumentViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var mainDocumentTextView: UITextView!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var notesTitle: UILabel!
    
    var document = Document()
    var editable: Bool = false
    var changesMade: Bool = false
    let db = Firestore.firestore()
    let signature = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if document.mainDocument != "" {
            mainDocumentTextView.isHidden = false
            imageView.isHidden = true
            viewButton.isHidden = true
            mainDocumentTextView.text = document.mainDocument
        }
        else {
            mainDocumentTextView.isHidden = true
            imageView.isHidden = false
            viewButton.isHidden = false
            if document.imageURL != nil {
                if let fileUrl = document.imageURL {
                    let url = URL(string: fileUrl)
                    URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.document.image = UIImage(data: data!)
                            self.imageView.image = UIImage(data: data!)
                        }
                    }.resume()
                }
            }
        }
        
        checkForSignature()
        titleLabel.text = document.title
        notesTextView.text = document.notes
        dateLabel.text = document.date
        
        
    }
    
    func checkForSignature() {
        
        if document.signatures.contains(signature) {
            awaitingSignatures()
        }
        else  {
            
            saveButton.isHidden = false
            reviewLabel.isHidden = true
            
            
        }
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        if editable == false {
            editable = true
            editButton.setTitle("Save", for: .normal)
            saveButton.setTitle("Revert changes", for: .normal)
            
            if mainDocumentTextView.isHidden == false{
                mainDocumentTextView.isEditable = true
            }
            notesTextView.isEditable = true
        }
        else{
            editable = false
            editButton.setTitle("Edit", for: .normal)
            saveButton.setTitle("Save document", for: .normal)
            if mainDocumentTextView.isHidden == false {
                mainDocumentTextView.isEditable = false
            }
            notesTextView.isEditable = false
            if mainDocumentTextView.text != document.mainDocument || notesTextView.text != document.notes {
                let alert = UIAlertController(title: "Changes made", message: "You have changed the text in either the main document or notes section, did you mean to make these changes? If no, press 'No' to discard the changes, otherwise 'Yes' if you wish to save these changes to send back to your landlord.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: {(action: UIAlertAction!) in
                    self.mainDocumentTextView.text = self.document.mainDocument
                    self.notesTextView.text = self.document.notes
                    self.changesMade = true
                    self.saveButton.setTitle("Submit changes", for: .normal)
                }))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                    self.saveButton.setTitle("Propose changes", for: .normal)
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if changesMade == true {
            let alert = UIAlertController(title: "Changes made", message: "You have saved changes to this document, tap 'Yes' to resubmit these your landlord for review. If you wish discard these changes and sign the orignal document, tap 'No' and then 'Revert changes' in edit mode.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                if self.mainDocumentTextView.text != self.document.mainDocument {
                    let newBody = self.mainDocumentTextView.text
                    self.db.collection("documents").document(self.document.documentID!).updateData(["Body" : newBody!])
                    self.db.collection("documents").document(self.document.documentID!).updateData(["Changed" : true])
                    self.saveButton.isHidden = true
                    self.reviewLabel.isHidden = false
                    self.changesMade = true
                }
                if self.notesTextView.text != self.document.notes {
                    let newNote = self.notesTextView.text
                    self.db.collection("documents").document(self.document.documentID!).updateData(["Notes": newNote!])
                    self.db.collection("documents").document(self.document.documentID!).updateData(["Changed" : true])
                    self.saveButton.isHidden = true
                    self.reviewLabel.isHidden = false
                    self.changesMade = true
                }
            }))
            self.present(alert, animated: true)
        }
        
        if changesMade == false {
            let alert = UIAlertController(title: "Confirm agreement", message: "If you have reviewed and agree with this document tap 'Yes' to provide your digital signature, otherwise tap 'No' if you do not wish to sign.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                
                let reason = "Provide biometric signature."
                let context = LAContext()
                var error: NSError?
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                        DispatchQueue.main.async {
                            if success {
                                self?.documentSigned()
                            }
                        }
                    }
                }
                else {
                    
                    let alert = UIAlertController(title: "Enable biometrics", message: "We recommend enables Touch/Face ID on this device to allow you to sign documents with your biometric ID, as this is much more secure. If this is unavailable then proceed with your passcode, otherwise please adjust your settings before signing any documents.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Passcode", style: .default, handler: {(action: UIAlertAction!) in
                        
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authenticationError in
                            DispatchQueue.main.async {
                                if success {
                                    self?.documentSigned()
                                }
                            }
                        }
                    }))
                    self.present(alert, animated: true)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    
    func documentSigned() {
        
        document.signatures.append(signature)
        let signaturesConfirmed = document.signatures.count
        
        if signaturesConfirmed == document.signatureCount {
            mainDocumentTextView.isHidden = true
            editButton.isHidden = true
            reviewLabel.text = "You have successfully signed this document. It can be viewed in the 'Documents' tab now all required signatures have been recieved."
            reviewLabel.isHidden = false
            viewButton.isHidden = true
            notesTextView.isHidden = true
            imageView.isHidden = true
            saveButton.isHidden = true
            notesTitle.isHidden = true
            
            db.collection("signed").addDocument(data: ["PropertyID": document.propertyID!, "Title" : document.title!,"Body": document.mainDocument ?? "","Notes": document.notes ?? "","Date": document.date!,"DocumentID": document.documentID!, "ImageURL": document.imageURL ?? ""]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    
                }
            }
            
            db.collection("documents").document(document.documentID!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        else if signaturesConfirmed != document.signatureCount{
            
            awaitingSignatures()
            //add a new signature to the "signature" array field for this document to count how many people have signed it
            db.collection("documents").document(document.documentID!).updateData([
                "Signatures": FieldValue.arrayUnion([signature])
            ])
            
        }
    }
    
    func awaitingSignatures() {
        
        if document.mainDocument != "" {
            
            mainDocumentTextView.isHidden = false
            viewButton.isHidden = true
        }
        else if imageView.image != nil {
            mainDocumentTextView.isHidden = true
            viewButton.isHidden = false
            imageView.isHidden = false
        }
        
        editable = false
        editButton.isHidden = true
        reviewLabel.isHidden = false
        reviewLabel.text = "You have successfully signed this document. It will remain here on the property notice board until all required signatures are received."
        saveButton.isHidden = true
        notesTextView.isHidden = true
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "showFullDocumentTenant", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ViewDocumentViewController {
            destination.image = document.image
            
        }
    }
}
