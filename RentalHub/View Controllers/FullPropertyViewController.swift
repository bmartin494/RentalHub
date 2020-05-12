//
//  FullPropertyViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 19/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class FullPropertyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var propertyIDLabel: UILabel!
    @IBOutlet weak var tenantsTableLabel: UILabel!
    @IBOutlet weak var tenantsTableView: UITableView!
    @IBOutlet weak var addDocumentsButton: UIBarButtonItem!

    let cellID = "cellID"
    var usersCollectionRef = Firestore.firestore().collection("users")
    var addressText: String?
    var cityText: String?
    var countyText: String?
    var postcodeText: String?
    var propertyID: String?
    var myIndex = 0
    var tenantName: String?
    var tenants = [Tenant]()
    var document = Document()
    var documentType: Int = 0
    var tenantCount: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        document.image = nil
        tenantsTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        
        tenantsTableView.delegate = self
        tenantsTableView.dataSource = self
        tenantsTableView.rowHeight = UITableView.automaticDimension
        tenantsTableView.tableFooterView = UIView()
        addressLabel.text = addressText
        cityLabel.text = cityText
        countyLabel.text = countyText
        postcodeLabel.text = postcodeText
        propertyIDLabel.text = propertyID
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.addDocumentsButton.image = .add
        documentType = 0

        //Checking whether tenant or landlord user
        usersCollectionRef.whereField("Assigned_Property", isEqualTo: propertyID!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                self.tenants.removeAll()
                for document in snapshot!.documents {
                    let data = document.data()
                    let firstname = data["First_Name"] as? String
                    let lastname = data["Last_Name"] as? String
                    let name = firstname! + " " + lastname!
                    let email = data["Email"] as? String
                    let phone = data["Phone"] as? String
                    let tenantDocumentID = document.documentID as String
 
                    let newTenant = Tenant()
                    newTenant.name = name
                    newTenant.email = email
                    newTenant.phone = phone
                    newTenant.tenantDocumentID = tenantDocumentID
                    self.tenants.append(newTenant)
                }
            }
            self.tenantsTableView.reloadData()
        }
    }
    
    @IBAction func addDocumentsTapped(_ sender: Any) {
        
        documentPicker()
        
    }
    
    
    func documentPicker() {
        let imagePicker = UIImagePickerController()
        
        let actionSheet = UIAlertController(title: "Post a new property document", message: nil, preferredStyle: .actionSheet)
        
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
        
        actionSheet.addAction(UIAlertAction(title: "Create new", style: .default, handler: { (action:UIAlertAction) in
            self.performSegue(withIdentifier: "addDocument", sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        imagePicker.delegate = self
        
    }
    @IBAction func copyIDtapped(_ sender: Any) {
        
        UIPasteboard.general.string = propertyIDLabel.text
        
        let alert = UIAlertController(title: "Success", message: "Property ID copied to clipboard.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tenants.count > 0 {
            return tenants.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.tertiarySystemGroupedBackground

        tenantsTableView.allowsSelection = false
        if tenants.count <= 0 {
            cell.textLabel?.text = "You currently have no tenants assigned"
            cell.detailTextLabel?.isHidden = true
            
        }
        else {
            let tenant = tenants[indexPath.row]
            cell.textLabel?.text = tenant.name
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = (tenant.email ?? "") + "    Phone: " + (tenant.phone ?? "No number available")

        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        myIndex = indexPath.row
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //functionality for swipe to delete cell record
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: "Remove tenant", message: "Are you sure you want to remove this tenant? They will have to request to be linked and approved again to be added back.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                let tenant = self.tenants[indexPath.row]

                self.usersCollectionRef.document(tenant.tenantDocumentID!).updateData([
                    "Assigned_Property": "",
                    "LinkRequest_Sent": false,
                    "LandlordID":""
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                self.tenants.remove(at: self.myIndex)
                self.tenantsTableView.reloadData()
            }))

            self.present(alert, animated: true)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? AddDocumentViewController {
            if documentType == 1 {
                destination.document.image = document.image
                destination.documentType = 1
            }
            else {
                destination.documentType = 0
            }
            destination.document.propertyID = propertyID
            tenantCount = tenants.count
            destination.document.signatureCount = tenantCount
        }
    }
    
    @IBAction func unwindToFullPropertyView( _ seg: UIStoryboardSegue) {}

}


extension FullPropertyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            document.image = imageSelected
            documentType = 1
            self.performSegue(withIdentifier: "addDocument", sender: self)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
