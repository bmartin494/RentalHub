//
//  AddDocumentViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 03/05/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class AddDocumentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var documentWriterTextView: UITextView!
    @IBOutlet weak var uploadDocumentButton: UIButton!
    @IBOutlet weak var viewDocumentButton: UIButton!
    @IBOutlet weak var signatureSwitch: UISwitch!
    @IBOutlet weak var documentNameTextField: UITextField!

    let db = Firestore.firestore()
    var document = Document()
    var image: UIImage? = nil
    var documentType: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if documentType == 1{
            imageView.isHidden = false
            imageView.image = image
            viewDocumentButton.isHidden = false
            
        }
        else if documentType == 0 {
            image = nil
            imageView.isHidden = true
            documentWriterTextView.isHidden = false
            viewDocumentButton.isHidden = true
            
        }
        
    }
    
    @IBAction func viewDocumentTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "viewDocument", sender: self)
        
    }
    
    @IBAction func uploadDocumentTapped(_ sender: Any) {
        
        if documentType == 0{
            if documentNameTextField.text == nil || documentWriterTextView?.text == "Write our your new document or message for your tennants in this main text view." {
                
                let alert = UIAlertController(title: "Incomplete fields", message: "Please ensure you have named the document and written something in the document text field before submitting.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else {
            if documentNameTextField.text == nil  {
                
                let alert = UIAlertController(title: "Incomplete fields", message: "Please ensure you have named the document before submitting.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
        
        if signatureSwitch.isOn{
        let alert = UIAlertController(title: "Signature required?", message: "You have required the tenant to review and provide a digital signature for this document, is this correct? If you just wish to post a notice to your tenants tap 'No' and switch the toggle, otherwise tap 'Yes'.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            
            self.signatureCheckUpload()
        }))
        present(alert, animated: true)
        performSegue(withIdentifier: "unwindToFullProperty", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Signature required?", message: "You have not required the tenant to review and provide a digital signature for this document, is this correct? If you require a signature for this document tap 'No' and switch the toggle, otherwise tap 'Yes'.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                
                self.signatureCheckUpload()
            }))
            present(alert, animated: true)
            performSegue(withIdentifier: "unwindToFullProperty", sender: self)
        }
    }
    
    func signatureCheckUpload() {
        var imageData: Data?
        
        if let imageSelected = self.imageView.image {
            imageData = imageSelected.jpegData(compressionQuality: 0.5)
        } else {
            print("image is nil")
        }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        if self.imageView.image != nil {
            let storageRef = Storage.storage().reference(forURL: "gs://rentalhub-82cfc.appspot.com")
            let reportRef = storageRef.child("documents").child("properties").child(self.document.propertyID!)
            
            reportRef.putData(imageData!, metadata: metaData, completion: { (storageMetaData, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                reportRef.downloadURL(completion: { (url, error) in
                    if let metaURL = url?.absoluteString{
                        
                        self.uploadDatabaseInfo(downloadStringURL: metaURL)
                    }
                })
            })
        } else {
            self.uploadDatabaseInfo(downloadStringURL: "nil")
        }
        self.documentWriterTextView.text = ""
        self.documentNameTextField.text = ""
        self.infoTextView.text = "Add any notes/instructions/questions relating to the document in here."
        self.image = nil
        let alert = UIAlertController(title: "Document posted successfully!", message: "Your tennant will be recieve this document on their property page. You can view documents you have posted for all your properties in the 'Documents' tab.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action: UIAlertAction!) in
            
            self.performSegue(withIdentifier: "unwindToFullProperty", sender: self)
        }))
    }
    
    
    func countTenants() {
        
        
    }
    
    //upload report data to database
    func uploadDatabaseInfo(downloadStringURL: String) {
        
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: today)
        
        let mainDocument = documentWriterTextView.text
        let name = documentNameTextField.text
        var notes = infoTextView.text
        if infoTextView.text == "Add any notes/instructions/questions relating to the document in here." {
            notes = ""
        }
        let signature = signatureSwitch.isOn
        
        
        db.collection("documents").addDocument(data: [ "PropertyID": document.propertyID!, "Title" : name!,"Body": mainDocument ?? "","Notes": notes ?? "","Date": formattedDate,"Require_Signature" : signature, "ImageURL": downloadStringURL,"Signature_Count": document.signatureCount!, "Signatures":[]])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ViewDocumentViewController {
            destination.image = image
            
        }
    }
    
}
