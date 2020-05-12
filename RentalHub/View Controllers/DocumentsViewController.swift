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
    var agreements = [Document]()
    var myIndex = 0
    var reportCollectionRef = Firestore.firestore().collection("reports")
    var userCollectionRef = Firestore.firestore().collection("users")
    var agreementsCollectionRef = Firestore.firestore().collection("signed")
    var assignedPropertyID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        agreementsTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        agreementsTableView.delegate = self
        agreementsTableView.dataSource = self
        agreementsTableView.rowHeight = UITableView.automaticDimension
        agreementsTableView.tableFooterView = UIView()
        
        reportsTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        reportsTableView.delegate = self
        reportsTableView.dataSource = self
        reportsTableView.rowHeight = UITableView.automaticDimension
        reportsTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getUserDetails()
    }
    
    func getUserDetails() {
        userCollectionRef.whereField("uid", isEqualTo: currentUser!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    let data = document.data()
                    self.assignedPropertyID = data["Assigned_Property"] as? String
                }
            }
            
            if self.assignedPropertyID != nil {
                self.getDocuments()
                self.getReports()
            }
        }
    }
    
    func getReports() {
        
        reportCollectionRef.whereField("PropertyID", isEqualTo: assignedPropertyID ?? "").getDocuments { (snapshot, error) in
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
    
    func getDocuments() {
        
        agreementsCollectionRef.whereField("PropertyID", isEqualTo: assignedPropertyID ?? "").getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                self.agreements.removeAll()
                for document in snapshot!.documents {
                    let data = document.data()
                    let documentID = document.documentID as String
                    let propertyID = data["PropertyID"] as? String
                    let title = data["Title"] as? String
                    let mainDocument = data["Body"] as? String
                    let notes = data["Notes"] as? String
                    let date = data["Date"] as? String
                    let signatureCount = data["Signature_Count"] as? Int
                    let signatures = data["Signatures"] as? Array<String>
                    let imageURL = data["ImageURL"] as? String
                    
                    let newDocument = Document()
                    newDocument.documentID = documentID
                    newDocument.propertyID = propertyID
                    newDocument.title = title
                    newDocument.mainDocument = mainDocument
                    newDocument.notes = notes
                    newDocument.signatureCount = signatureCount
                    newDocument.signatures = signatures ?? []
                    newDocument.date = date
                    newDocument.imageURL = imageURL
                    
                    self.agreements.append(newDocument)
                }
                self.reportsTableView.reloadData()
                self.agreementsTableView.reloadData()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == agreementsTableView {
            if agreements.count <= 0 {
                return 1
            }
            else{
                return agreements.count
            }
        }
        if tableView == reportsTableView {
            if reports.count <= 0 {
                return 1
            }
            else{
                return reports.count
            }
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.tertiarySystemGroupedBackground
        
        if tableView == reportsTableView {
            if reports.count == 0 {
                reportsTableView.allowsSelection = false
                cell.textLabel?.text = "No reports stored"
                
            }
            else {
                let report = reports[indexPath.row]
                reportsTableView.allowsSelection = true
                cell.textLabel?.text = report.issue
                cell.detailTextLabel?.text = report.issueDescription
                
            }
        }
        
        if tableView == agreementsTableView {
            if agreements.count <= 0 {
                agreementsTableView.allowsSelection = false
                cell.textLabel?.text = "No documents stored"
                cell.detailTextLabel?.text = nil
                
            }
            else{
                agreementsTableView.allowsSelection = true
                let agreement = agreements[indexPath.row]
                cell.textLabel?.text = agreement.title
                cell.detailTextLabel?.text = nil
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        myIndex = indexPath.row
        if tableView == reportsTableView {
            performSegue(withIdentifier: "showReport", sender: self)
        }
        
        if tableView == agreementsTableView {
            performSegue(withIdentifier: "showSignedDocument", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //functionality for swipe to delete cell record
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) && tableView == agreementsTableView{
            let alert = UIAlertController(title: "Delete document", message: "Are you sure you want to delete this document? It will be no longer be able to be viewed by any other people who have signed it.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
                let document = self.agreements[indexPath.row]

                self.agreementsCollectionRef.document(document.documentID!).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                self.agreements.remove(at: self.myIndex)
                self.agreementsTableView.reloadData()
            }))

            self.present(alert, animated: true)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? FullReportViewController {
            let report = reports[myIndex]
            destination.propertyText = report.property
            destination.dateText = report.date
            destination.issueText = report.issue
            destination.descriptionText = report.issueDescription
            if report.imageURL != "nil" {
                destination.imageURL = report.imageURL
            }
            else {
                destination.imageURL = nil
            }
        }
        
        if let destination = segue.destination as? SignedDocumentViewController {
            let document = agreements[myIndex]
            destination.document.title = document.title
            destination.document.mainDocument = document.mainDocument
            if document.imageURL != nil {
                destination.document.imageURL = document.imageURL

            }
            else {
                destination.document.imageURL = nil
            }
            destination.document.date = document.date
            destination.document.notes = document.notes
            destination.document.deleteCount = document.deleteCount
        }
    }
    
}




