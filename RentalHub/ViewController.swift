//
//  ViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 07/01/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController{

//    var ref: DatabaseReference!
//    var databaseHandle: DatabaseHandle!
//    var postData = [String]()
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //database reference
//        ref = Database.database().reference()
//        
//        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
//            let dataDict = snapshot.value as? NSDictionary
//        }
        
    }
    
    
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//           return postData.count
//       }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
//        cell?.textLabel?.text = postData[indexPath.row]
//
//        return cell!
//    }
//
//    @IBAction func submitForm(_ sender: Any) {
//
//        guard let image = imageView.image,
//        let data = image.jpegData(compressionQuality: 1.0)
//            else {
//                return
//        }
//
//        let imageName = UUID().uuidString
//        let imageReference = Storage.storage().reference()
//
//        self.ref.child("users").childByAutoId().setValue(["name":nameTextfield.text, "age":ageTextfield.text, "city":cityTextfield.text])
//
//    }
//
//
//    @IBAction func addImageBtn(_ sender: Any) {
//
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//
//        let actionSheet = UIAlertController(title: "Select photo location", message: nil, preferredStyle: .actionSheet)
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//         actionSheet.addAction(UIAlertAction(title:"Camera", style: .default, handler: { (action:UIAlertAction) in
//            imagePickerController.sourceType = .camera
//            self.present(imagePickerController, animated: true, completion: nil)
//         }))
//        }
//
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//        actionSheet.addAction(UIAlertAction(title:"Photo Library", style: .default, handler: { (action:UIAlertAction) in
//            imagePickerController.sourceType = .photoLibrary
//            self.present(imagePickerController, animated: true, completion: nil)
//        }))
//        }
//
//        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
//
//            self.present(actionSheet, animated: true, completion: nil)
//
//        }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//
//       // imageView.image = image
//
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
}

    

