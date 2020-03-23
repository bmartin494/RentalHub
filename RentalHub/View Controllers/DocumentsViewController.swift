//
//  DocumentsViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 20/03/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellID = "cellID"

    @IBOutlet weak var reportsTableView: UITableView!
    @IBOutlet weak var agreementsTableView: UITableView!
    
    var currentUser = Auth.auth().currentUser?.uid
    var db = Firestore.firestore()
    var reports = [Report]()
    let agreements = [String]()
    var documentCollectionRef = Firestore.firestore().collection("reports")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agreementsTableView.delegate = self
        agreementsTableView.dataSource = self
        agreementsTableView.rowHeight = UITableView.automaticDimension
        reportsTableView.delegate = self
        reportsTableView.dataSource = self
        reportsTableView.rowHeight = UITableView.automaticDimension
        reportsTableView.tableFooterView = UIView()
        agreementsTableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        documentCollectionRef.whereField("UserID", isEqualTo: currentUser!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                self.reports.removeAll()
                for document in snapshot!.documents {
                    let data = document.data()
                    let property = data["Property"] as? String
                    let issue = data["Issue"] as? String
                    let issueDescription = data["Description"] as? String
                    let date = data["Date"] as? String
                    let userID = data["UserID"] as? String
                    let reportID = data["ReportID"] as? String
                    let imageURL = data["ImageURL"] as? String
                    
                    let newReport = Report()
                    newReport.property = property
                    newReport.issue = issue
                    newReport.issueDescription = issueDescription
                    newReport.date = date
                    newReport.userID = userID
                    newReport.uid = reportID
                    newReport.imageURL = imageURL
        
                    self.reports.append(newReport)
                }
                self.reportsTableView.reloadData()
                self.agreementsTableView.reloadData()
                
            }
        }
    }
    
    func userCheck() {
        db.collection("users").whereField("uid", isEqualTo: currentUser)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID)")
                        let data = document.data()
                        let accountType = data["account_type"]
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == agreementsTableView {
            if agreements.count == 0 {
                return 1
            }
            else{
                return agreements.count
            }
        }
        if tableView == reportsTableView {
            return reports.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        if tableView == reportsTableView {
            let report = reports[indexPath.row]
            cell.textLabel?.text = report.issue
            cell.detailTextLabel?.text = report.issueDescription
        }
        
        if tableView == agreementsTableView {
            if agreements.count == 0 {
                cell.textLabel?.text = "No documents stored"
                cell.detailTextLabel?.text = nil
            }
            else{
                let agreement = agreements[indexPath.row]
                cell.textLabel?.text = agreement
                cell.detailTextLabel?.text = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell clicked")
    }

}
