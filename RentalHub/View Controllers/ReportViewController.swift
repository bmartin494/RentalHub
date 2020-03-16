//
//  ReportViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 26/02/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class ReportViewController: UIViewController {

    @IBOutlet weak var issuePickerTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var riskSwitch: UISwitch!
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var attachImageLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var alternativeIssueTextField: UITextField!
    
    var image: UIImage? = nil
    
    let issues = ["Electrical",
                  "Plumbing",
                  "Kitchen Appliances",
                  "Heating",
                  "Security",
                  "Other"]
    
    var selectedIssue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createIssuePicker()
        createToolbar()
        riskSwitch.addTarget(self, action: #selector(ReportViewController.switchIsChanged(riskSwitch:)), for: UIControl.Event.valueChanged)
    }
    

    func createIssuePicker() {
        let issuePicker = UIPickerView()
        issuePicker.delegate = self
        
        issuePickerTextField.inputView = issuePicker
    }
    
    func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ReportViewController.dismissKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        issuePickerTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func switchIsChanged(riskSwitch: UISwitch) {
        if riskSwitch.isOn {
            let alert = UIAlertController(title: "Is this an emergency?", message: "DO NOT use this system as an alternative in an instance where the emergency services are required. If there is immediate risk of crime or serious injury to a person contact the emergency services now.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } 
    }
    @IBAction func selectImageTapped(_ sender: Any) {
        if selectedImageView.isHidden == true {
        presentPicker()
        }
        else if selectedImageView.isHidden == false {
            selectedImageView.isHidden = true
            uploadImageBtn.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            attachImageLabel.text = "Attach an image"
            selectedImageView.image = nil
        }
    }
    
    func presentPicker() {
        
        let imagePicker = UIImagePickerController()

        let actionSheet = UIAlertController(title: "Select photo location", message: nil, preferredStyle: .actionSheet)

         if UIImagePickerController.isSourceTypeAvailable(.camera) {
         actionSheet.addAction(UIAlertAction(title:"Camera", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
         }))
        }

         if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        actionSheet.addAction(UIAlertAction(title:"Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        }

         actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))

             self.present(actionSheet, animated: true, completion: nil)
        imagePicker.delegate = self
        
         }
    

    @IBAction func submitBtnTapped(_ sender: Any) {

        let reportID = UUID().uuidString
        let db = Firestore.firestore()
        
        db.collection("reports").document(Auth.auth().currentUser!.uid).collection("reports_from_user").addDocument(data: ["Issue":selectedIssue, "Description":descriptionTextField.text, "uid": reportID])
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
        }
        guard let imageSelected = self.image else {
            print("image is nil")
            return
        }
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.5) else {
            return
        }
        let storageRef = Storage.storage().reference(forURL: "gs://rentalhub-82cfc.appspot.com/reports/users/" + Auth.auth().currentUser!.uid)
        let storageReportRef = storageRef.child(reportID)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageReportRef.putData(imageData, metadata: metaData) { (storageMetaData, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    
}

extension ReportViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIssue = issues[row]
        issuePickerTextField.text = selectedIssue
        if selectedIssue == "Other" {
            alternativeIssueTextField.isHidden = false
        }
        else {
            alternativeIssueTextField.isHidden = true
        }
    }
}

extension ReportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageSelected
            selectedImageView.image = imageSelected
            selectedImageView.isHidden = false
            attachImageLabel.text = "Remove image"
            uploadImageBtn.setImage(UIImage(systemName: "clear.fill"), for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
