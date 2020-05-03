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
    @IBOutlet weak var tennantsTableLabel: UILabel!
    @IBOutlet weak var tennantsTableView: UITableView!
    @IBOutlet weak var addDocumentsButton: UIBarButtonItem!
    
    
    let cellID = "cellID"
    var usersCollectionRef = Firestore.firestore().collection("users")
    var addressText: String?
    var cityText: String?
    var countyText: String?
    var postcodeText: String?
    var propertyIDText: String?
    var myIndex = 0
    var tennantName: String?
    var tennants = [Tennant]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tennantsTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        
        tennantsTableView.delegate = self
        tennantsTableView.dataSource = self
        tennantsTableView.rowHeight = UITableView.automaticDimension
        tennantsTableView.tableFooterView = UIView()
        addressLabel.text = addressText
        cityLabel.text = cityText
        countyLabel.text = countyText
        postcodeLabel.text = postcodeText
        propertyIDLabel.text = propertyIDText
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.addDocumentsButton.image = .add
        
//        let addDocumentButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(addDocumentTapped))
//        self.navigationItem.rightBarButtonItem  = addDocumentButton

        //self.navigationItem.rightBarButtonItem?.image = .add
        //Checking whether tenant or landlord user
        usersCollectionRef.whereField("Assigned_Property", isEqualTo: propertyIDText!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    let data = document.data()
                    let firstname = data["First_Name"] as? String
                    let lastname = data["Last_Name"] as? String
                    let name = firstname! + " " + lastname!
                    let email = data["Email"] as? String
                    let phone = data["Phone"] as? String
                    
                    let newTennant = Tennant()
                    newTennant.name = name
                    newTennant.email = email
                    newTennant.phone = phone
                    self.tennants.append(newTennant)
                }
            }
            self.tennantsTableView.reloadData()
        }
    }
    
    @IBAction func addDocumentsTapped(_ sender: Any) {
        print("This works")
    }
    
    
    @IBAction func copyIDtapped(_ sender: Any) {
        
        UIPasteboard.general.string = propertyIDLabel.text
        
        let alert = UIAlertController(title: "Success", message: "Property ID copied to clipboard.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tennants.count > 0 {
            return tennants.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        tennantsTableView.allowsSelection = false
        if tennants.count <= 0 {
            cell.textLabel?.text = "You currently have no tennants assigned"
            cell.detailTextLabel?.isHidden = true
            
        }
        else {
            let tennant = tennants[indexPath.row]
            cell.textLabel?.text = tennant.name
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = (tennant.email ?? "") + "    Phone: " + (tennant.phone ?? "No number available")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        myIndex = indexPath.row
        
    }
}
